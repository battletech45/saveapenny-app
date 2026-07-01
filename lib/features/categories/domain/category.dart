import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

enum CategoryType { income, expense }

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    String? userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Category;
}
