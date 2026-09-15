import 'package:drift/drift.dart';

enum CategoryKind { expense, income, both }

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get iconKey => text()();
  TextColumn get hexColor => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  /// Seeded defaults; users can edit them but not delete.
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  IntColumn get kind =>
      intEnum<CategoryKind>().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

enum TxnType { expense, income }

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  RealColumn get amount => real()();
  IntColumn get type => intEnum<TxnType>()();
  TextColumn get merchant => text().withDefault(const Constant(''))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get receiptPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BudgetSettings extends Table {
  IntColumn get id => integer()();
  RealColumn get monthlyCap => real().withDefault(const Constant(0))();
  RealColumn get monthlyIncome => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  IntColumn get id => integer()();
  BoolColumn get appLockEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get bioUnlockEnabled =>
      boolean().withDefault(const Constant(false))();
  /// Always on in product; kept for backups / older rows.
  BoolColumn get hideBalancesOnSwitch =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get encryptionActive =>
      boolean().withDefault(const Constant(true))();
  /// Seconds of no interaction while Kash is open before locking.
  /// `0` = off (leaving the app still locks immediately when lock is on).
  IntColumn get lockTimeoutSeconds =>
      integer().withDefault(const Constant(0))();
  /// Daily local notification at 8:30 PM to log expenses.
  BoolColumn get dailyExpenseReminderEnabled =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
