import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores DB / backup keys and a salted hash of the app unlock PIN.
class VaultKeyStore {
  static const _dbKeyName = 'kash_db_passphrase';
  static const _backupKeyName = 'kash_backup_key';
  static const _pinHashName = 'kash_pin_hash';
  static const _pinSaltName = 'kash_pin_salt';
  static const _pinFailCountName = 'kash_pin_fail_count';
  static const _pinLockoutStageName = 'kash_pin_lockout_stage';
  static const _pinLockoutUntilName = 'kash_pin_lockout_until';
  static const _securityQuestionName = 'kash_security_question';
  static const _securityAnswerHashName = 'kash_security_answer_hash';
  static const _securityAnswerSaltName = 'kash_security_answer_salt';

  final FlutterSecureStorage _storage;

  const VaultKeyStore([
    this._storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  ]);

  Future<String> getOrCreateDbPassphrase() async {
    final existing = await _storage.read(key: _dbKeyName);
    if (existing != null && existing.isNotEmpty) return existing;

    final bytes = _secureBytes(32);
    final passphrase = base64UrlEncode(bytes);
    await _storage.write(key: _dbKeyName, value: passphrase);
    return passphrase;
  }

  Future<Uint8List> getOrCreateBackupKey() async {
    final existing = await _storage.read(key: _backupKeyName);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Url.decode(existing));
    }

    final bytes = _secureBytes(32);
    await _storage.write(key: _backupKeyName, value: base64UrlEncode(bytes));
    return bytes;
  }

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _pinHashName);
    final salt = await _storage.read(key: _pinSaltName);
    return hash != null &&
        hash.isNotEmpty &&
        salt != null &&
        salt.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    _assertPin(pin);
    final salt = _secureBytes(16);
    final hash = _hashPin(pin, salt);
    await _storage.write(key: _pinSaltName, value: base64UrlEncode(salt));
    await _storage.write(key: _pinHashName, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    if (!_isValidPinFormat(pin)) return false;
    final saltB64 = await _storage.read(key: _pinSaltName);
    final expected = await _storage.read(key: _pinHashName);
    if (saltB64 == null || expected == null) return false;
    final salt = base64Url.decode(saltB64);
    return _hashPin(pin, Uint8List.fromList(salt)) == expected;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinHashName);
    await _storage.delete(key: _pinSaltName);
    await clearPinLockoutState();
    await clearSecurityQuestion();
  }

  Future<bool> hasSecurityQuestion() async {
    final q = await _storage.read(key: _securityQuestionName);
    final hash = await _storage.read(key: _securityAnswerHashName);
    final salt = await _storage.read(key: _securityAnswerSaltName);
    return q != null &&
        q.isNotEmpty &&
        hash != null &&
        hash.isNotEmpty &&
        salt != null &&
        salt.isNotEmpty;
  }

  Future<String?> securityQuestion() async {
    final q = await _storage.read(key: _securityQuestionName);
    if (q == null || q.isEmpty) return null;
    return q;
  }

  Future<void> setSecurityQuestion({
    required String question,
    required String answer,
  }) async {
    final q = question.trim();
    final a = _normalizeAnswer(answer);
    if (q.isEmpty || a.length < 2) {
      throw ArgumentError('Question and answer are required');
    }
    final salt = _secureBytes(16);
    final hash = _hashSecret(a, salt);
    await _storage.write(key: _securityQuestionName, value: q);
    await _storage.write(
      key: _securityAnswerSaltName,
      value: base64UrlEncode(salt),
    );
    await _storage.write(key: _securityAnswerHashName, value: hash);
  }

  Future<bool> verifySecurityAnswer(String answer) async {
    final saltB64 = await _storage.read(key: _securityAnswerSaltName);
    final expected = await _storage.read(key: _securityAnswerHashName);
    if (saltB64 == null || expected == null) return false;
    final salt = base64Url.decode(saltB64);
    return _hashSecret(_normalizeAnswer(answer), Uint8List.fromList(salt)) ==
        expected;
  }

  Future<void> clearSecurityQuestion() async {
    await _storage.delete(key: _securityQuestionName);
    await _storage.delete(key: _securityAnswerHashName);
    await _storage.delete(key: _securityAnswerSaltName);
  }

  String _normalizeAnswer(String answer) =>
      answer.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String _hashSecret(String secret, List<int> salt) {
    final bytes = <int>[...salt, ...utf8.encode(secret)];
    return sha256.convert(bytes).toString();
  }

  Future<({int failCount, int stage, DateTime? until})> readPinLockoutState() async {
    final failRaw = await _storage.read(key: _pinFailCountName);
    final stageRaw = await _storage.read(key: _pinLockoutStageName);
    final untilRaw = await _storage.read(key: _pinLockoutUntilName);
    DateTime? until;
    if (untilRaw != null && untilRaw.isNotEmpty) {
      until = DateTime.tryParse(untilRaw);
    }
    return (
      failCount: int.tryParse(failRaw ?? '') ?? 0,
      stage: int.tryParse(stageRaw ?? '') ?? 0,
      until: until,
    );
  }

  Future<void> writePinLockoutState({
    required int failCount,
    required int stage,
    DateTime? until,
  }) async {
    await _storage.write(key: _pinFailCountName, value: '$failCount');
    await _storage.write(key: _pinLockoutStageName, value: '$stage');
    if (until == null) {
      await _storage.delete(key: _pinLockoutUntilName);
    } else {
      await _storage.write(
        key: _pinLockoutUntilName,
        value: until.toIso8601String(),
      );
    }
  }

  Future<void> clearPinLockoutState() async {
    await _storage.delete(key: _pinFailCountName);
    await _storage.delete(key: _pinLockoutStageName);
    await _storage.delete(key: _pinLockoutUntilName);
  }

  Future<void> wipeKeys() async {
    await _storage.delete(key: _dbKeyName);
    await _storage.delete(key: _backupKeyName);
    await clearPin();
  }

  String _hashPin(String pin, List<int> salt) {
    return _hashSecret(pin, salt);
  }

  void _assertPin(String pin) {
    if (!_isValidPinFormat(pin)) {
      throw ArgumentError('PIN must be exactly 4 digits');
    }
  }

  bool _isValidPinFormat(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);

  Uint8List _secureBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}
