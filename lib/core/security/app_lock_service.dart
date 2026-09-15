import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../database/database.dart';
import 'vault_key_store.dart';

class AppLockService {
  AppLockService({
    required VaultKeyStore keys,
    required AppDatabase db,
    LocalAuthentication? auth,
  })  : _keys = keys,
        _db = db,
        _auth = auth ?? LocalAuthentication();

  final VaultKeyStore _keys;
  final AppDatabase _db;
  final LocalAuthentication _auth;

  /// Wrong PINs allowed before a lockout starts.
  static const maxAttempts = 3;

  /// Escalating lockout lengths after each full set of failed attempts.
  static const lockoutDurations = <Duration>[
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 60),
  ];

  int _failedAttempts = 0;
  int _lockoutStage = 0;
  DateTime? _lockoutUntil;
  bool _restored = false;

  Future<void> restoreLockoutState() async {
    if (_restored) return;
    final state = await _keys.readPinLockoutState();
    _failedAttempts = state.failCount;
    _lockoutStage = state.stage;
    _lockoutUntil = state.until;
    _restored = true;
    // Clear expired lockout windows but keep stage so the next set escalates.
    _refreshLockoutWindow();
  }

  Future<void> _persistLockoutState() async {
    await _keys.writePinLockoutState(
      failCount: _failedAttempts,
      stage: _lockoutStage,
      until: _lockoutUntil,
    );
  }

  void _refreshLockoutWindow() {
    final until = _lockoutUntil;
    if (until == null) return;
    if (DateTime.now().isAfter(until)) {
      _lockoutUntil = null;
      _failedAttempts = 0;
      // Keep _lockoutStage so the next lockout is longer.
      unawaited(_persistLockoutState());
    }
  }

  bool get isInLockout {
    _refreshLockoutWindow();
    return _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);
  }

  int get lockoutRemainingSeconds {
    _refreshLockoutWindow();
    final until = _lockoutUntil;
    if (until == null) return 0;
    final s = until.difference(DateTime.now()).inSeconds;
    return s < 0 ? 0 : s;
  }

  int get attemptsRemaining {
    if (isInLockout) return 0;
    final left = maxAttempts - _failedAttempts;
    return left < 0 ? 0 : left;
  }

  Future<bool> hasPin() => _keys.hasPin();

  Future<bool> deviceSupportsBio() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      if (!canCheck && !supported) return false;
      final types = await _auth.getAvailableBiometrics();
      return types.isNotEmpty || supported;
    } catch (_) {
      return false;
    }
  }

  Future<AppSetting?> settings() =>
      (_db.select(_db.appSettings)..where((t) => t.id.equals(1)))
          .getSingleOrNull();

  Future<bool> isLockEnabled() async {
    final s = await settings();
    final has = await hasPin();
    return (s?.appLockEnabled ?? false) && has;
  }

  Future<bool> isBioUnlockEnabled() async {
    final s = await settings();
    return (s?.bioUnlockEnabled ?? false) && await deviceSupportsBio();
  }

  Future<void> setPinAndEnableLock(String pin) async {
    await _keys.setPin(pin);
    await _writeSettings(appLockEnabled: true);
    await _resetAttempts();
  }

  Future<bool> hasSecurityQuestion() => _keys.hasSecurityQuestion();

  Future<String?> securityQuestion() => _keys.securityQuestion();

  Future<void> setSecurityQuestion({
    required String question,
    required String answer,
  }) {
    return _keys.setSecurityQuestion(question: question, answer: answer);
  }

  Future<bool> verifySecurityAnswer(String answer) =>
      _keys.verifySecurityAnswer(answer);

  Future<void> clearSecurityQuestion() => _keys.clearSecurityQuestion();

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    await restoreLockoutState();
    if (isInLockout) return false;
    final ok = await _keys.verifyPin(currentPin);
    if (!ok) {
      await _registerFailure();
      return false;
    }
    await _keys.setPin(newPin);
    await _resetAttempts();
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    await restoreLockoutState();
    if (isInLockout) return false;
    final ok = await _keys.verifyPin(pin);
    if (ok) {
      await _resetAttempts();
      return true;
    }
    await _registerFailure();
    return false;
  }

  Future<bool> unlockWithBio() async {
    if (!await isBioUnlockEnabled()) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock Kash',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> confirmWithBio() async {
    if (!await deviceSupportsBio()) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Confirm it’s you',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> replacePin(String newPin) async {
    await _keys.setPin(newPin);
    await _resetAttempts();
  }

  Future<void> enableBioUnlock() async {
    if (!await hasPin()) {
      throw StateError('PIN required before enabling fingerprint unlock');
    }
    if (!await deviceSupportsBio()) {
      throw StateError('Fingerprint or Face ID not available');
    }
    final ok = await confirmWithBio();
    if (!ok) throw StateError('Could not verify fingerprint or Face ID');
    await _writeSettings(bioUnlockEnabled: true);
  }

  Future<void> disableBioUnlock() async {
    await _writeSettings(bioUnlockEnabled: false);
  }

  Future<void> disableLock() async {
    await _keys.clearPin();
    await _writeSettings(appLockEnabled: false, bioUnlockEnabled: false);
    await _resetAttempts();
  }

  Future<void> _writeSettings({
    bool? appLockEnabled,
    bool? bioUnlockEnabled,
    int? lockTimeoutSeconds,
  }) async {
    final current = await settings();
    await _db.upsertAppSettings(
      AppSettingsCompanion(
        id: const Value(1),
        appLockEnabled: Value(
          appLockEnabled ?? current?.appLockEnabled ?? false,
        ),
        bioUnlockEnabled: Value(
          bioUnlockEnabled ?? current?.bioUnlockEnabled ?? false,
        ),
        hideBalancesOnSwitch: const Value(true),
        encryptionActive: Value(current?.encryptionActive ?? true),
        lockTimeoutSeconds: Value(
          lockTimeoutSeconds ?? current?.lockTimeoutSeconds ?? 0,
        ),
        dailyExpenseReminderEnabled: Value(
          current?.dailyExpenseReminderEnabled ?? true,
        ),
      ),
    );
  }

  Future<void> setLockTimeoutSeconds(int seconds) async {
    await _writeSettings(lockTimeoutSeconds: seconds);
  }

  Future<void> _registerFailure() async {
    _failedAttempts++;
    if (_failedAttempts >= maxAttempts) {
      final index = _lockoutStage.clamp(0, lockoutDurations.length - 1);
      _lockoutUntil = DateTime.now().add(lockoutDurations[index]);
      _failedAttempts = 0;
      if (_lockoutStage < lockoutDurations.length - 1) {
        _lockoutStage++;
      }
    }
    await _persistLockoutState();
  }

  Future<void> _resetAttempts() async {
    _failedAttempts = 0;
    _lockoutStage = 0;
    _lockoutUntil = null;
    await _keys.clearPinLockoutState();
  }
}
