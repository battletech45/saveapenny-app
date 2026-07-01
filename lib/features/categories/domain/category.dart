import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

enum CategoryType { system, user }

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    String? parentId,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Category;
}
