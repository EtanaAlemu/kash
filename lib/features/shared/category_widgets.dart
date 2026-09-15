import 'package:flutter/material.dart';

import '../../core/database/tables.dart';
import '../../core/theme/kash_theme.dart';

/// Whether a category can be used for the given transaction type.
bool categoryMatchesTxnType(CategoryKind kind, TxnType type) {
  if (kind == CategoryKind.both) return true;
  return type == TxnType.expense
      ? kind == CategoryKind.expense
      : kind == CategoryKind.income;
}

String labelForCategoryKind(CategoryKind kind) {
  switch (kind) {
    case CategoryKind.expense:
      return 'Expense';
    case CategoryKind.income:
      return 'Income';
    case CategoryKind.both:
      return 'Both';
  }
}

/// Icons available when creating or editing a category.
const kCategoryIconKeys = <String>[
  'restaurant',
  'directions_car',
  'home',
  'bolt',
  'shopping_cart',
  'movie',
  'local_hospital',
  'work',
  'school',
  'pets',
  'flight',
  'fitness',
  'coffee',
  'gift',
  'savings',
  'category',
];

/// Colors available when creating or editing a category.
const kCategoryColorHexes = <String>[
  '#34C759',
  '#FFB340',
  '#64D2FF',
  '#BF5AF2',
  '#FF9F0A',
  '#FF375F',
  '#30D158',
  '#0A84FF',
  '#FF453A',
  '#AC8E68',
  '#5E5CE6',
  '#FFD60A',
];

IconData iconForKey(String key) {
  switch (key) {
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'directions_car':
      return Icons.directions_car_rounded;
    case 'home':
      return Icons.home_rounded;
    case 'bolt':
      return Icons.bolt_rounded;
    case 'shopping_cart':
      return Icons.shopping_cart_rounded;
    case 'movie':
      return Icons.movie_rounded;
    case 'local_hospital':
      return Icons.local_hospital_rounded;
    case 'work':
      return Icons.work_rounded;
    case 'school':
      return Icons.school_rounded;
    case 'pets':
      return Icons.pets_rounded;
    case 'flight':
      return Icons.flight_rounded;
    case 'fitness':
      return Icons.fitness_center_rounded;
    case 'coffee':
      return Icons.local_cafe_rounded;
    case 'gift':
      return Icons.card_giftcard_rounded;
    case 'savings':
      return Icons.savings_rounded;
    case 'category':
      return Icons.category_rounded;
    default:
      return Icons.category_rounded;
  }
}

Color colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value =
      int.parse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
  return Color(value);
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.iconKey,
    required this.hexColor,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final String iconKey;
  final String hexColor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(hexColor);
    return Material(
      color: selected ? color.withValues(alpha: 0.25) : KashColors.surfaceElevated,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconForKey(iconKey), size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? KashColors.textPrimary
                      : KashColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
