import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database_provider.dart';
import '../../core/theme/kash_theme.dart';
import '../shared/category_widgets.dart';
import '../shared/money_format.dart';
import '../shared/providers.dart';
import '../vault/backup_service.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);
    final totals = ref.watch(analyticsCategoryTotalsProvider);
    final weekly = ref.watch(weeklySpendProvider);
    final merchants = ref.watch(topMerchantsProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          PopupMenuButton<AnalyticsPeriod>(
            initialValue: period,
            onSelected: (p) =>
                ref.read(analyticsPeriodProvider.notifier).state = p,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AnalyticsPeriod.week,
                child: Text('Week'),
              ),
              const PopupMenuItem(
                value: AnalyticsPeriod.month,
                child: Text('Month'),
              ),
              const PopupMenuItem(
                value: AnalyticsPeriod.year,
                child: Text('Year'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    period == AnalyticsPeriod.month
                        ? DateFormat('MMM yyyy').format(now)
                        : period.name[0].toUpperCase() + period.name.substring(1),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Save spreadsheet',
            onPressed: () async {
              try {
                final db = await ref.read(databaseProvider.future);
                final keys = ref.read(vaultKeyStoreProvider);
                final file = await BackupService(db, keys).exportCsv();
                if (file == null || !context.mounted) return;
                debugPrint('Kash CSV saved: ${file.path}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Spreadsheet saved:\n${file.path}'),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Couldn’t save your spending. Try again.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Text(
            'Where money went',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          totals.when(
            data: (list) {
              if (list.isEmpty) {
                return const Text(
                  'No spending in this period.',
                  style: TextStyle(color: KashColors.textSecondary),
                );
              }
              final sum = list.fold<double>(0, (s, e) => s + e.amount);
              return Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: [
                          for (final item in list)
                            PieChartSectionData(
                              color: colorFromHex(item.category.hexColor),
                              value: item.amount,
                              title:
                                  '${((item.amount / sum) * 100).round()}%',
                              radius: 28,
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in list.take(5))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colorFromHex(item.category.hexColor),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(item.category.name)),
                                Text(formatMoney(item.amount)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 140,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 32),
          Text(
            'This week',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: weekly.when(
              data: (days) {
                final maxY = days.fold<double>(0, (m, v) => v > m ? v : m);
                return BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final i = value.toInt();
                            if (i < 0 || i > 6) return const SizedBox.shrink();
                            return Text(
                              labels[i],
                              style: const TextStyle(
                                color: KashColors.textSecondary,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < days.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: days[i],
                              width: 16,
                              borderRadius: BorderRadius.circular(6),
                              color: KashColors.fab,
                            ),
                          ],
                        ),
                    ],
                    maxY: maxY <= 0 ? 10 : maxY * 1.2,
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Top places',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          merchants.when(
            data: (list) {
              if (list.isEmpty) {
                return const Text(
                  'No places yet.',
                  style: TextStyle(color: KashColors.textSecondary),
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        '${i + 1}.',
                        style: const TextStyle(
                          color: KashColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      title: Text(list[i].merchant),
                      subtitle: Text(
                        list[i].count == 1
                            ? '1 purchase'
                            : '${list[i].count} purchases',
                      ),
                      trailing: Text(
                        formatMoney(list[i].amount),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}
