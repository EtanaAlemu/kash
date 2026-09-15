import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/theme/kash_theme.dart';
import '../shared/category_widgets.dart';
import '../shared/money_edit_dialog.dart';
import '../shared/money_format.dart';
import '../shared/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _editMonthlyCap(
    BuildContext context,
    WidgetRef ref,
    double currentCap,
  ) async {
    final result = await showMoneyEditDialog(
      context,
      title: 'Monthly spending limit',
      current: currentCap > 0 ? currentCap : 0,
      hint: '0',
      label: 'How much can you spend this month?',
    );
    if (result == null) return;

    final db = await ref.read(databaseProvider.future);
    final existing = await ref.read(budgetSettingsProvider.future);
    await db.upsertBudgetSettings(
      BudgetSettingsCompanion(
        id: const Value(1),
        monthlyCap: Value(result),
        monthlyIncome: Value(existing?.monthlyIncome ?? 0),
      ),
    );
  }

  Future<void> _editMonthlyIncome(
    BuildContext context,
    WidgetRef ref,
    double currentIncome,
  ) async {
    final result = await showMoneyEditDialog(
      context,
      title: 'Monthly income',
      current: currentIncome > 0 ? currentIncome : 0,
      hint: '0',
      label: 'How much do you expect to earn?',
    );
    if (result == null) return;

    final db = await ref.read(databaseProvider.future);
    final existing = await ref.read(budgetSettingsProvider.future);
    await db.upsertBudgetSettings(
      BudgetSettingsCompanion(
        id: const Value(1),
        monthlyCap: Value(existing?.monthlyCap ?? 0),
        monthlyIncome: Value(result),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spend = ref.watch(monthSpendProvider);
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);
    final filterId = ref.watch(selectedCategoryFilterProvider);
    final settings = ref.watch(appSettingsProvider);
    final lockOn = settings.valueOrNull?.appLockEnabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, size: 18, color: KashColors.accentGreen),
            SizedBox(width: 8),
            Text('Kash'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: Icon(
                lockOn ? Icons.lock_rounded : Icons.lock_open_rounded,
                size: 16,
                color: lockOn
                    ? KashColors.accentGreen
                    : KashColors.textSecondary,
              ),
              label: Text(
                lockOn ? 'Lock on' : 'On this phone',
                style: const TextStyle(fontSize: 12),
              ),
              visualDensity: VisualDensity.compact,
              backgroundColor: KashColors.surfaceElevated,
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_add_fab',
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionsProvider);
          ref.invalidate(budgetSettingsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            spend.when(
              data: (snap) => Column(
                children: [
                  _BudgetGaugeCard(
                    spent: snap.spent,
                    cap: snap.cap,
                    remaining: snap.remaining,
                    ratio: snap.ratio,
                    daysLeft: snap.daysLeft,
                    obscured: false,
                    onEditCap: () => _editMonthlyCap(context, ref, snap.cap),
                  ),
                  const SizedBox(height: 12),
                  _IncomeCard(
                    earned: snap.earned,
                    incomeTarget: snap.incomeTarget,
                    incomeRatio: snap.incomeRatio,
                    daysLeft: snap.daysLeft,
                    obscured: false,
                    onEditTarget: () =>
                        _editMonthlyIncome(context, ref, snap.incomeTarget),
                  ),
                ],
              ),
              loading: () => const _LoadingCard(),
              error: (e, _) => const Text('Couldn’t load your budget.'),
            ),
            const SizedBox(height: 24),
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            categories.when(
              data: (cats) {
                final favorites = cats.where((c) => c.isFavorite).toList();
                return SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CategoryChip(
                          label: 'All',
                          iconKey: 'category',
                          hexColor: '#0A84FF',
                          selected: filterId == null,
                          onTap: () => ref
                              .read(selectedCategoryFilterProvider.notifier)
                              .state = null,
                        );
                      }
                      final c = favorites[index - 1];
                      return CategoryChip(
                        label: c.name,
                        iconKey: c.iconKey,
                        hexColor: c.hexColor,
                        selected: filterId == c.id,
                        onTap: () => ref
                            .read(selectedCategoryFilterProvider.notifier)
                            .state = c.id,
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(height: 42),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Recent',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/analytics'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            transactions.when(
              data: (list) {
                final filtered = filterId == null
                    ? list
                    : list.where((t) => t.categoryId == filterId).toList();
                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No transactions yet. Tap + to add one.',
                      style: TextStyle(color: KashColors.textSecondary),
                    ),
                  );
                }
                final cats = categories.valueOrNull ?? [];
                final catMap = {
                  for (final c in cats) c.id: c,
                };
                return Column(
                  children: [
                    for (final t in filtered.take(20))
                      _TxnTile(
                        merchant: t.merchant.isEmpty
                            ? (t.type.name == 'expense' ? 'Expense' : 'Income')
                            : t.merchant,
                        subtitle: formatTxnTime(t.timestamp),
                        amount: t.amount,
                        isExpense: t.type.name == 'expense',
                        iconKey: catMap[t.categoryId]?.iconKey ?? 'category',
                        hexColor: catMap[t.categoryId]?.hexColor ?? '#0A84FF',
                        onTap: () => context.push('/edit/${t.id}'),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetGaugeCard extends StatelessWidget {
  const _BudgetGaugeCard({
    required this.spent,
    required this.cap,
    required this.remaining,
    required this.ratio,
    required this.daysLeft,
    required this.obscured,
    required this.onEditCap,
  });

  final double spent;
  final double cap;
  final double remaining;
  final double ratio;
  final int daysLeft;
  final bool obscured;
  final VoidCallback onEditCap;

  @override
  Widget build(BuildContext context) {
    final color = KashColors.gaugeForProgress(ratio);
    final pct = (ratio * 100).clamp(0, 999).toStringAsFixed(0);

    return Material(
      color: KashColors.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onEditCap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KashColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'SPENDING',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: KashColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                obscured
                    ? '••••'
                    : cap <= 0
                        ? formatMoney(spent)
                        : '${formatMoney(spent)} / ${formatMoney(cap)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (cap <= 0) ...[
                const SizedBox(height: 12),
                const Text(
                  'Tap to set your monthly spending limit',
                  style: TextStyle(color: KashColors.textSecondary),
                ),
              ] else ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: KashColors.border,
                    color: color,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '$pct% used',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        obscured
                            ? 'Left: •••• · $daysLeft days'
                            : 'Left: ${formatMoney(remaining)} · $daysLeft days',
                        style:
                            const TextStyle(color: KashColors.textSecondary),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  const _IncomeCard({
    required this.earned,
    required this.incomeTarget,
    required this.incomeRatio,
    required this.daysLeft,
    required this.obscured,
    required this.onEditTarget,
  });

  final double earned;
  final double incomeTarget;
  final double incomeRatio;
  final int daysLeft;
  final bool obscured;
  final VoidCallback onEditTarget;

  @override
  Widget build(BuildContext context) {
    final pct = (incomeRatio * 100).clamp(0, 999).toStringAsFixed(0);

    return Material(
      color: KashColors.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onEditTarget,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KashColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'INCOME',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: KashColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                obscured
                    ? '••••'
                    : incomeTarget <= 0
                        ? formatMoney(earned)
                        : '${formatMoney(earned)} / ${formatMoney(incomeTarget)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: KashColors.accentGreen,
                    ),
              ),
              if (incomeTarget <= 0) ...[
                const SizedBox(height: 12),
                const Text(
                  'Tap to set your monthly income',
                  style: TextStyle(color: KashColors.textSecondary),
                ),
              ] else ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: incomeRatio.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: KashColors.border,
                    color: KashColors.accentGreen,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '$pct% of goal',
                      style: const TextStyle(
                        color: KashColors.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$daysLeft days left',
                      style: const TextStyle(color: KashColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({
    required this.merchant,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    required this.iconKey,
    required this.hexColor,
    required this.onTap,
  });

  final String merchant;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final String iconKey;
  final String hexColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(hexColor);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(iconForKey(iconKey), color: color, size: 20),
      ),
      title: Text(merchant, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
      trailing: Text(
        '${isExpense ? '-' : '+'}${formatMoney(amount)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isExpense ? KashColors.textPrimary : KashColors.accentGreen,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: KashColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}
