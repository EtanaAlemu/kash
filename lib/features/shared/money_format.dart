import 'package:intl/intl.dart';

final moneyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
final moneyCompact = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

String formatMoney(double value) => moneyFormat.format(value);

String formatTxnTime(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  final time = DateFormat('h:mm a').format(dt);

  if (day == today) return 'Today, $time';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('MMM d').format(dt);
}

String groupLabelFor(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('MMM d, yyyy').format(dt);
}

int daysLeftInMonth([DateTime? now]) {
  final n = now ?? DateTime.now();
  final last = DateTime(n.year, n.month + 1, 0);
  return last.day - n.day + 1;
}
