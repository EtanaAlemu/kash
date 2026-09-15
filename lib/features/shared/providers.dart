import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/tables.dart';
import '../shared/money_format.dart';

final categoriesProvider = StreamProvider<List<Category>>((ref) async* {
  final db = await ref.watch(databaseProvider.future);
  yield* db.watchCategories();
});

final transactionsProvider = StreamProvider<List<Transaction>>((ref) async* {
  final db = await ref.watch(databaseProvider.future);
  yield* db.watchRecentTransactions();
});

final budgetSettingsProvider = StreamProvider<BudgetSetting?>((ref) async* {
  final db = await ref.watch(databaseProvider.future);
  yield* db.watchBudgetSettings();
});

final appSettingsProvider = StreamProvider<AppSetting?>((ref) async* {
  final db = await ref.watch(databaseProvider.future);
  yield* db.watchAppSettings();
});

final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Bumped after a full data wipe so [UnlockGate] can clear lock session state.
final dataResetTickProvider = StateProvider<int>((ref) => 0);

class MonthMoneySnapshot {
  const MonthMoneySnapshot({
    required this.spent,
    required this.earned,
    required this.cap,
    required this.incomeTarget,
    required this.remaining,
    required this.ratio,
    required this.incomeRatio,
    required this.daysLeft,
  });

  final double spent;
  final double earned;
  final double cap;
  final double incomeTarget;
  final double remaining;
  final double ratio;
  final double incomeRatio;
  final int daysLeft;
}

final monthSpendProvider = Provider<AsyncValue<MonthMoneySnapshot>>((ref) {
  final txns = ref.watch(transactionsProvider);
  final budget = ref.watch(budgetSettingsProvider);

  return txns.when(
    data: (list) {
      return budget.when(
        data: (settings) {
          final now = DateTime.now();
          bool thisMonth(Transaction t) =>
              t.timestamp.year == now.year && t.timestamp.month == now.month;

          final spent = list
              .where((t) => t.type == TxnType.expense && thisMonth(t))
              .fold<double>(0, (sum, t) => sum + t.amount);
          final earned = list
              .where((t) => t.type == TxnType.income && thisMonth(t))
              .fold<double>(0, (sum, t) => sum + t.amount);
          final cap = settings?.monthlyCap ?? 0;
          final incomeTarget = settings?.monthlyIncome ?? 0;
          final remaining = (cap - spent).clamp(0, double.infinity).toDouble();
          final ratio = cap <= 0 ? 0.0 : (spent / cap).clamp(0.0, 2.0);
          final incomeRatio = incomeTarget <= 0
              ? 0.0
              : (earned / incomeTarget).clamp(0.0, 2.0);
          return AsyncValue.data(
            MonthMoneySnapshot(
              spent: spent,
              earned: earned,
              cap: cap,
              incomeTarget: incomeTarget,
              remaining: remaining,
              ratio: ratio,
              incomeRatio: incomeRatio,
              daysLeft: daysLeftInMonth(now),
            ),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
      );
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

class CategoryTotal {
  const CategoryTotal({
    required this.category,
    required this.amount,
  });

  final Category category;
  final double amount;
}

class MerchantTotal {
  const MerchantTotal({
    required this.merchant,
    required this.amount,
    required this.count,
  });

  final String merchant;
  final double amount;
  final int count;
}

enum AnalyticsPeriod { week, month, year }

final analyticsPeriodProvider =
    StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.month);

DateTimeRange periodRange(AnalyticsPeriod period, DateTime now) {
  switch (period) {
    case AnalyticsPeriod.week:
      final start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      return DateTimeRange(start: start, end: now);
    case AnalyticsPeriod.month:
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      );
    case AnalyticsPeriod.year:
      return DateTimeRange(start: DateTime(now.year, 1, 1), end: now);
  }
}

class DateTimeRange {
  const DateTimeRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  bool contains(DateTime dt) =>
      !dt.isBefore(start) && !dt.isAfter(end.add(const Duration(days: 1)));
}

final analyticsCategoryTotalsProvider =
    Provider<AsyncValue<List<CategoryTotal>>>((ref) {
  final cats = ref.watch(categoriesProvider);
  final txns = ref.watch(transactionsProvider);
  final period = ref.watch(analyticsPeriodProvider);

  return cats.when(
    data: (categories) {
      return txns.when(
        data: (list) {
          final range = periodRange(period, DateTime.now());
          final map = <String, double>{};
          for (final t in list) {
            if (t.type != TxnType.expense) continue;
            if (!range.contains(t.timestamp)) continue;
            map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
          }
          final totals = categories
              .map(
                (c) => CategoryTotal(category: c, amount: map[c.id] ?? 0),
              )
              .where((c) => c.amount > 0)
              .toList()
            ..sort((a, b) => b.amount.compareTo(a.amount));
          return AsyncValue.data(totals);
        },
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
      );
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

final weeklySpendProvider = Provider<AsyncValue<List<double>>>((ref) {
  final txns = ref.watch(transactionsProvider);
  return txns.when(
    data: (list) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final days = List<double>.filled(7, 0);
      for (final t in list) {
        if (t.type != TxnType.expense) continue;
        final day = DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
        final diff = day.difference(start).inDays;
        if (diff >= 0 && diff < 7) {
          days[diff] += t.amount;
        }
      }
      return AsyncValue.data(days);
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

final topMerchantsProvider = Provider<AsyncValue<List<MerchantTotal>>>((ref) {
  final txns = ref.watch(transactionsProvider);
  final period = ref.watch(analyticsPeriodProvider);
  return txns.when(
    data: (list) {
      final range = periodRange(period, DateTime.now());
      final map = <String, MerchantTotal>{};
      for (final t in list) {
        if (t.type != TxnType.expense) continue;
        if (!range.contains(t.timestamp)) continue;
        final name = t.merchant.trim().isEmpty ? 'Unknown' : t.merchant.trim();
        final prev = map[name];
        map[name] = MerchantTotal(
          merchant: name,
          amount: (prev?.amount ?? 0) + t.amount,
          count: (prev?.count ?? 0) + 1,
        );
      }
      final sorted = map.values.toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
      return AsyncValue.data(sorted.take(5).toList());
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});
