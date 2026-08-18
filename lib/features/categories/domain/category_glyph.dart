import 'package:flutter/material.dart';

/// Keyword -> icon mapping for `Category.icon`. Shared between the read-side
/// [CategoryIcon] and the [CategoryGlyphPicker] so both stay in sync — the
/// keyword a user picks is exactly the keyword later rendered as an icon.
const Map<String, IconData> categoryIconOptions = <String, IconData>{
  'shopping': Icons.shopping_bag_outlined,
  'food': Icons.restaurant_outlined,
  'transport': Icons.directions_car_outlined,
  'home': Icons.home_outlined,
  'entertainment': Icons.movie_outlined,
  'health': Icons.medical_services_outlined,
  'education': Icons.school_outlined,
  'salary': Icons.trending_up_rounded,
  'savings': Icons.account_balance_outlined,
  'bills': Icons.receipt_long_outlined,
  'travel': Icons.flight_outlined,
  'category': Icons.category_outlined,
};

IconData parseCategoryIcon(String? iconName) {
  return switch (iconName?.toLowerCase()) {
    'shopping' => Icons.shopping_bag_outlined,
    'food' || 'restaurant' => Icons.restaurant_outlined,
    'transport' || 'car' => Icons.directions_car_outlined,
    'home' || 'housing' => Icons.home_outlined,
    'entertainment' => Icons.movie_outlined,
    'health' || 'medical' => Icons.medical_services_outlined,
    'education' => Icons.school_outlined,
    'salary' || 'income' => Icons.trending_up_rounded,
    'savings' || 'investment' => Icons.account_balance_outlined,
    'bills' || 'utilities' => Icons.receipt_long_outlined,
    'travel' => Icons.flight_outlined,
    _ => Icons.category_outlined,
  };
}

/// Fixed hex palette offered by the [CategoryGlyphPicker] — kept separate
/// from [ChartPalette] (which is for chart series, not persisted category
/// colors) since these values round-trip through the backend as hex
/// strings on `Category.color`.
const List<String> categoryColorHexOptions = <String>[
  '3B5BC0',
  '2E9E8F',
  'B07A12',
  '8A5FD1',
  'C0574A',
  '3E8ECF',
  '6E8B3D',
  'C0568E',
];

Color parseCategoryColor(String hex) {
  final buffer = StringBuffer();
  if (hex.startsWith('#')) {
    buffer.write('FF');
    buffer.write(hex.substring(1));
  } else {
    buffer.write('FF$hex');
  }
  return Color(int.parse(buffer.toString(), radix: 16));
}
