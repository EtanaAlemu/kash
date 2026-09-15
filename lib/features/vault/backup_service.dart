import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:pointycastle/export.dart' hide Digest;

import '../../core/database/database.dart';
import '../../core/database/tables.dart';
import '../../core/security/vault_key_store.dart';
import 'export_location.dart';

class BackupService {
  BackupService(this._db, this._keys);

  final AppDatabase _db;
  final VaultKeyStore _keys;

  /// Returns the saved file, or `null` if the user cancelled.
  Future<File?> exportKashBackup() async {
    final categories = await _db.select(_db.categories).get();
    final transactions = await _db.select(_db.transactions).get();
    final budget = await _db.select(_db.budgetSettings).get();
    final settings = await _db.select(_db.appSettings).get();

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'iconKey': c.iconKey,
              'hexColor': c.hexColor,
              'isFavorite': c.isFavorite,
              'sortOrder': c.sortOrder,
              'isBuiltin': c.isBuiltin,
              'kind': c.kind.name,
            },
          )
          .toList(),
      'transactions': transactions
          .map(
            (t) => {
              'id': t.id,
              'categoryId': t.categoryId,
              'amount': t.amount,
              'type': t.type.name,
              'merchant': t.merchant,
              'note': t.note,
              'timestamp': t.timestamp.toIso8601String(),
              'receiptPath': t.receiptPath,
            },
          )
          .toList(),
      'budgetSettings': budget
          .map(
            (b) => {
              'id': b.id,
              'monthlyCap': b.monthlyCap,
              'monthlyIncome': b.monthlyIncome,
            },
          )
          .toList(),
      'appSettings': settings
          .map(
            (s) => {
              'id': s.id,
              'appLockEnabled': s.appLockEnabled,
              'bioUnlockEnabled': s.bioUnlockEnabled,
              'hideBalancesOnSwitch': true,
              'encryptionActive': s.encryptionActive,
              'lockTimeoutSeconds': s.lockTimeoutSeconds,
              'dailyExpenseReminderEnabled': s.dailyExpenseReminderEnabled,
            },
          )
          .toList(),
    };

    final plaintext = utf8.encode(jsonEncode(payload));
    final key = await _keys.getOrCreateBackupKey();
    final encrypted = _aesGcmEncrypt(key, Uint8List.fromList(plaintext));

    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return saveToUserAccessibleLocation(
      fileName: 'kash_backup_$stamp.kash',
      bytes: encrypted,
      dialogTitle: 'Save Kash backup',
    );
  }

  /// Returns the saved file, or `null` if the user cancelled.
  Future<File?> exportCsv() async {
    final transactions = await _db.select(_db.transactions).get();
    final categories = {
      for (final c in await _db.select(_db.categories).get()) c.id: c.name,
    };

    final buffer = StringBuffer('id,type,amount,category,merchant,timestamp\n');
    for (final t in transactions) {
      buffer.writeln(
        '${t.id},${t.type.name},${t.amount},${categories[t.categoryId] ?? ''},'
        '"${t.merchant.replaceAll('"', '""')}",${t.timestamp.toIso8601String()}',
      );
    }

    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return saveToUserAccessibleLocation(
      fileName: 'kash_export_$stamp.csv',
      bytes: utf8.encode(buffer.toString()),
      dialogTitle: 'Save spending spreadsheet',
    );
  }

  Future<void> importKashBackup(File file) async {
    final bytes = await file.readAsBytes();
    final key = await _keys.getOrCreateBackupKey();
    final plaintext = _aesGcmDecrypt(key, Uint8List.fromList(bytes));
    final json = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;

    await _db.wipeAllData();

    final categoryRows = (json['categories'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final txnRows = (json['transactions'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final budgetRows = (json['budgetSettings'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final settingsRows = (json['appSettings'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    await _db.batch((b) {
      for (final c in categoryRows) {
        b.insert(
          _db.categories,
          CategoriesCompanion.insert(
            id: c['id'] as String,
            name: c['name'] as String,
            iconKey: c['iconKey'] as String,
            hexColor: c['hexColor'] as String,
            isFavorite: Value(c['isFavorite'] as bool? ?? false),
            sortOrder: Value(c['sortOrder'] as int? ?? 0),
            isBuiltin: Value(c['isBuiltin'] as bool? ?? false),
            kind: Value(
              CategoryKind.values.byName(
                c['kind'] as String? ?? 'expense',
              ),
            ),
          ),
        );
      }
      for (final t in txnRows) {
        b.insert(
          _db.transactions,
          TransactionsCompanion.insert(
            id: t['id'] as String,
            categoryId: t['categoryId'] as String,
            amount: (t['amount'] as num).toDouble(),
            type: TxnType.values.byName(t['type'] as String),
            merchant: Value(t['merchant'] as String? ?? ''),
            note: Value(t['note'] as String?),
            timestamp: DateTime.parse(t['timestamp'] as String),
            receiptPath: Value(t['receiptPath'] as String?),
          ),
        );
      }
      for (final s in budgetRows) {
        b.insert(
          _db.budgetSettings,
          BudgetSettingsCompanion.insert(
            id: Value(s['id'] as int),
            monthlyCap: Value((s['monthlyCap'] as num).toDouble()),
            monthlyIncome: Value((s['monthlyIncome'] as num).toDouble()),
          ),
        );
      }
      for (final s in settingsRows) {
        b.insert(
          _db.appSettings,
          AppSettingsCompanion.insert(
            id: Value(s['id'] as int),
            appLockEnabled: Value(
              s['appLockEnabled'] as bool? ??
                  s['requireBiometrics'] as bool? ??
                  false,
            ),
            bioUnlockEnabled: Value(s['bioUnlockEnabled'] as bool? ?? false),
            hideBalancesOnSwitch: const Value(true),
            encryptionActive: Value(s['encryptionActive'] as bool? ?? true),
            lockTimeoutSeconds: Value(
              (s['lockTimeoutSeconds'] as num?)?.toInt() ?? 0,
            ),
            dailyExpenseReminderEnabled: Value(
              s['dailyExpenseReminderEnabled'] as bool? ?? true,
            ),
          ),
        );
      }
    });
  }

  Uint8List _aesGcmEncrypt(Uint8List key, Uint8List plaintext) {
    final iv = Uint8List.fromList(
      List<int>.generate(12, (_) => Random.secure().nextInt(256)),
    );
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    final cipherText = cipher.process(plaintext);
    // Format: version(1) | iv(12) | ciphertext+tag
    return Uint8List.fromList([1, ...iv, ...cipherText]);
  }

  Uint8List _aesGcmDecrypt(Uint8List key, Uint8List data) {
    if (data.length < 14 || data[0] != 1) {
      throw StateError('Invalid .kash backup format');
    }
    final iv = data.sublist(1, 13);
    final cipherText = data.sublist(13);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    return cipher.process(cipherText);
  }
}

/// Simple integrity helper used by tests / debug.
Digest sha256Of(List<int> bytes) => sha256.convert(bytes);
