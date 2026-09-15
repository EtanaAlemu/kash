import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:uuid/uuid.dart';

import '../security/vault_key_store.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions, BudgetSettings, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.deleteTable('app_settings');
            await m.createTable(appSettings);
            await into(appSettings).insert(
              AppSettingsCompanion.insert(
                id: const Value(1),
                appLockEnabled: const Value(false),
                bioUnlockEnabled: const Value(false),
                hideBalancesOnSwitch: const Value(true),
                encryptionActive: const Value(true),
                lockTimeoutSeconds: const Value(0),
                dailyExpenseReminderEnabled: const Value(true),
              ),
            );
          }
          if (from < 3) {
            // Clear only the old hardcoded demo defaults (not user-set amounts).
            await customStatement(
              'UPDATE budget_settings SET monthly_cap = 0 '
              'WHERE monthly_cap = 2500',
            );
            await customStatement(
              'UPDATE budget_settings SET monthly_income = 0 '
              'WHERE monthly_income = 4800',
            );
          }
          if (from < 4) {
            await m.addColumn(categories, categories.isBuiltin);
            // Existing rows were all seeded before custom categories existed.
            await customStatement(
              'UPDATE categories SET is_builtin = 1',
            );
          }
          if (from < 5) {
            await m.addColumn(categories, categories.kind);
            // Existing categories were all spend-oriented.
            await customStatement('UPDATE categories SET kind = 0');
            await _seedBuiltinIncomeCategories();
          }
          if (from < 6) {
            await m.addColumn(appSettings, appSettings.lockTimeoutSeconds);
            await customStatement(
              'UPDATE app_settings SET hide_balances_on_switch = 1, '
              'lock_timeout_seconds = 0',
            );
          }
          if (from < 7) {
            await m.addColumn(
              appSettings,
              appSettings.dailyExpenseReminderEnabled,
            );
          }
        },
      );

  static Future<AppDatabase> open({VaultKeyStore? keyStore}) async {
    final keys = keyStore ?? const VaultKeyStore();
    final passphrase = await keys.getOrCreateDbPassphrase();

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    }

    final executor = LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'kash_secure.db'));

      return NativeDatabase.createInBackground(
        file,
        isolateSetup: () {
          if (Platform.isAndroid) {
            sqlite3_open.open.overrideFor(
              sqlite3_open.OperatingSystem.android,
              openCipherOnAndroid,
            );
          }
        },
        setup: (rawDb) {
          final version = rawDb.select('PRAGMA cipher_version');
          if (version.isEmpty) {
            throw StateError('SQLCipher library is not available');
          }
          final escaped = passphrase.replaceAll("'", "''");
          rawDb.execute("PRAGMA key = '$escaped'");
          rawDb.execute('SELECT count(*) FROM sqlite_master');
        },
      );
    });

    final db = AppDatabase(executor);
    await db._ensureSeeded();
    return db;
  }

  Future<void> _ensureSeeded() async {
    final existing = await select(categories).get();
    if (existing.isNotEmpty) return;
    await seedDefaults();
  }

  Future<void> seedDefaults() async {
    // First launch: categories only — no demo spending or fake budget numbers.
    await _seedCategoriesAndSettings(includeSampleTransactions: false);
  }

  Future<void> _seedCategoriesAndSettings({
    required bool includeSampleTransactions,
  }) async {
    const uuid = Uuid();
    final now = DateTime.now();

    final foodId = uuid.v4();
    final transportId = uuid.v4();
    final housingId = uuid.v4();
    final billsId = uuid.v4();
    final shoppingId = uuid.v4();
    final funId = uuid.v4();
    final healthId = uuid.v4();
    final salaryId = uuid.v4();
    final freelanceId = uuid.v4();
    final giftsId = uuid.v4();
    final otherIncomeId = uuid.v4();

    await batch((b) {
      b.insertAll(categories, [
        CategoriesCompanion.insert(
          id: foodId,
          name: 'Food',
          iconKey: 'restaurant',
          hexColor: '#34C759',
          isFavorite: const Value(true),
          sortOrder: const Value(0),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.expense),
        ),
        CategoriesCompanion.insert(
          id: transportId,
          name: 'Transport',
          iconKey: 'directions_car',
          hexColor: '#FFB340',
          isFavorite: const Value(true),
          sortOrder: const Value(1),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.expense),
        ),
        CategoriesCompanion.insert(
          id: housingId,
          name: 'Housing',
          iconKey: 'home',
          hexColor: '#64D2FF',
          isFavorite: const Value(true),
          sortOrder: const Value(2),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.expense),
        ),
        CategoriesCompanion.insert(
          id: billsId,
          name: 'Bills',
          iconKey: 'bolt',
          hexColor: '#BF5AF2',
          isFavorite: const Value(true),
          sortOrder: const Value(3),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.expense),
        ),
        CategoriesCompanion.insert(
          id: shoppingId,
          name: 'Shopping',
          iconKey: 'shopping_cart',
          hexColor: '#FF9F0A',
          sortOrder: const Value(4),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.expense),
        ),
        CategoriesCompanion.insert(
          id: funId,
          name: 'Fun',
          iconKey: 'movie',
          hexColor: '#FF375F',
          sortOrder: const Value(5),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.expense),
        ),
        CategoriesCompanion.insert(
          id: healthId,
          name: 'Health',
          iconKey: 'local_hospital',
          hexColor: '#30D158',
          sortOrder: const Value(6),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.expense),
        ),
        CategoriesCompanion.insert(
          id: salaryId,
          name: 'Salary',
          iconKey: 'work',
          hexColor: '#30D158',
          isFavorite: const Value(true),
          sortOrder: const Value(7),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.income),
        ),
        CategoriesCompanion.insert(
          id: freelanceId,
          name: 'Freelance',
          iconKey: 'savings',
          hexColor: '#0A84FF',
          sortOrder: const Value(8),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.income),
        ),
        CategoriesCompanion.insert(
          id: giftsId,
          name: 'Gifts',
          iconKey: 'gift',
          hexColor: '#FF375F',
          sortOrder: const Value(9),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.income),
        ),
        CategoriesCompanion.insert(
          id: otherIncomeId,
          name: 'Other income',
          iconKey: 'category',
          hexColor: '#5E5CE6',
          sortOrder: const Value(10),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.income),
        ),
      ]);

      b.insert(
        budgetSettings,
        BudgetSettingsCompanion.insert(
          id: const Value(1),
          monthlyCap: const Value(0),
          monthlyIncome: const Value(0),
        ),
      );

      b.insert(
        appSettings,
        AppSettingsCompanion.insert(
          id: const Value(1),
          appLockEnabled: const Value(false),
          bioUnlockEnabled: const Value(false),
          hideBalancesOnSwitch: const Value(true),
          encryptionActive: const Value(true),
          lockTimeoutSeconds: const Value(0),
          dailyExpenseReminderEnabled: const Value(true),
        ),
      );

      if (includeSampleTransactions) {
        b.insertAll(transactions, [
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: foodId,
            amount: 42.10,
            type: TxnType.expense,
            merchant: const Value('Grocery Market'),
            timestamp: DateTime(now.year, now.month, now.day, 14, 15),
          ),
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: transportId,
            amount: 35.00,
            type: TxnType.expense,
            merchant: const Value('Fuel Filling'),
            timestamp: DateTime(now.year, now.month, now.day)
                .subtract(const Duration(days: 1)),
          ),
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: foodId,
            amount: 5.50,
            type: TxnType.expense,
            merchant: const Value('Coffee Shop'),
            timestamp: DateTime(now.year, now.month, 12, 9, 30),
          ),
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: housingId,
            amount: 850.00,
            type: TxnType.expense,
            merchant: const Value('Monthly Rent'),
            timestamp: DateTime(now.year, now.month, 1, 10),
          ),
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: foodId,
            amount: 280.00,
            type: TxnType.expense,
            merchant: const Value('Local Supermarket'),
            timestamp: DateTime(now.year, now.month, 5, 16),
          ),
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: foodId,
            amount: 92.90,
            type: TxnType.expense,
            merchant: const Value('Local Supermarket'),
            timestamp: DateTime(now.year, now.month, 8, 11),
          ),
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: transportId,
            amount: 120.00,
            type: TxnType.expense,
            merchant: const Value('City Gas Station'),
            timestamp: DateTime(now.year, now.month, 3, 18),
          ),
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: billsId,
            amount: 95.00,
            type: TxnType.expense,
            merchant: const Value('Electric Utility'),
            timestamp: DateTime(now.year, now.month, 4, 12),
          ),
        ]);
      }
    });
  }

  /// Adds built-in income categories on upgrade if they are missing.
  Future<void> _seedBuiltinIncomeCategories() async {
    final existing = await select(categories).get();
    final names = existing.map((c) => c.name.toLowerCase()).toSet();
    var sort = existing.isEmpty
        ? 0
        : existing.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    const uuid = Uuid();

    Future<void> addIfMissing({
      required String name,
      required String iconKey,
      required String hexColor,
      bool favorite = false,
    }) async {
      if (names.contains(name.toLowerCase())) return;
      await into(categories).insert(
        CategoriesCompanion.insert(
          id: uuid.v4(),
          name: name,
          iconKey: iconKey,
          hexColor: hexColor,
          isFavorite: Value(favorite),
          sortOrder: Value(sort++),
          isBuiltin: const Value(true),
          kind: const Value(CategoryKind.income),
        ),
      );
    }

    await addIfMissing(
      name: 'Salary',
      iconKey: 'work',
      hexColor: '#30D158',
      favorite: true,
    );
    await addIfMissing(
      name: 'Freelance',
      iconKey: 'savings',
      hexColor: '#0A84FF',
    );
    await addIfMissing(
      name: 'Gifts',
      iconKey: 'gift',
      hexColor: '#FF375F',
    );
    await addIfMissing(
      name: 'Other income',
      iconKey: 'category',
      hexColor: '#5E5CE6',
    );
  }

  Future<void> wipeAllData() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(categories).go();
      await delete(budgetSettings).go();
      await delete(appSettings).go();
    });
  }

  /// Wipes everything and creates a clean start (categories + budget, no demo spending).
  Future<void> resetToBlankSlate() async {
    await wipeAllData();
    await _seedCategoriesAndSettings(includeSampleTransactions: false);
  }

  Stream<List<Category>> watchCategories() {
    return (select(categories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  Future<int> nextCategorySortOrder() async {
    final rows = await select(categories).get();
    if (rows.isEmpty) return 0;
    return rows.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> insertCategory(CategoriesCompanion companion) {
    return into(categories).insert(companion);
  }

  Future<void> updateCategory(String id, CategoriesCompanion companion) {
    return (update(categories)..where((c) => c.id.equals(id))).write(companion);
  }

  Future<int> countTransactionsForCategory(String categoryId) async {
    final count = countAll();
    final query = selectOnly(transactions)
      ..addColumns([count])
      ..where(transactions.categoryId.equals(categoryId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Moves transactions off [categoryId] then deletes the category.
  /// Built-in categories cannot be deleted.
  Future<void> deleteCategory({
    required String categoryId,
    String? reassignToCategoryId,
  }) async {
    final existing = await (select(categories)
          ..where((c) => c.id.equals(categoryId)))
        .getSingleOrNull();
    if (existing == null) return;
    if (existing.isBuiltin) {
      throw StateError('Built-in categories can’t be deleted');
    }

    await transaction(() async {
      final usage = await countTransactionsForCategory(categoryId);
      if (usage > 0) {
        if (reassignToCategoryId == null ||
            reassignToCategoryId == categoryId) {
          throw StateError(
            'Move spending to another category before deleting',
          );
        }
        await (update(transactions)
              ..where((t) => t.categoryId.equals(categoryId)))
            .write(
              TransactionsCompanion(categoryId: Value(reassignToCategoryId)),
            );
      }
      await (delete(categories)..where((c) => c.id.equals(categoryId))).go();
    });
  }

  Stream<List<Transaction>> watchRecentTransactions({int limit = 50}) {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch();
  }

  Future<Transaction?> getTransactionById(String id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateTransaction(String id, TransactionsCompanion companion) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(companion);
  }

  Future<int> deleteTransaction(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  Stream<BudgetSetting?> watchBudgetSettings() {
    return (select(budgetSettings)..where((t) => t.id.equals(1)))
        .watchSingleOrNull();
  }

  Stream<AppSetting?> watchAppSettings() {
    return (select(appSettings)..where((t) => t.id.equals(1)))
        .watchSingleOrNull();
  }

  Future<void> upsertAppSettings(AppSettingsCompanion companion) {
    return into(appSettings).insertOnConflictUpdate(companion);
  }

  Future<void> upsertBudgetSettings(BudgetSettingsCompanion companion) {
    return into(budgetSettings).insertOnConflictUpdate(companion);
  }
}
