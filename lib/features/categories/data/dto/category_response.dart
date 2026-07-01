import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/categories/domain/category.dart';

part 'category_response.freezed.dart';
part 'category_response.g.dart';

@freezed
abstract class CategoryResponse with _$CategoryResponse {
  const factory CategoryResponse({
    required String id,
    required String name,
    required String type,
    String? icon,
    String? color,
    String? parentId,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CategoryResponse;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);
}

extension CategoryResponseX on CategoryResponse {
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      type: _categoryTypeFromWire(type),
      icon: icon,
      color: color,
      parentId: parentId,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

CategoryType _categoryTypeFromWire(String value) {
  return switch (value.toUpperCase()) {
    'SYSTEM' => CategoryType.system,
    _ => CategoryType.user,
  };
}
