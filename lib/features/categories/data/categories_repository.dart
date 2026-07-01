import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/categories/data/categories_api.dart';
import 'package:saveapenny/features/categories/data/dto/category_response.dart';
import 'package:saveapenny/features/categories/data/dto/create_category_request.dart';
import 'package:saveapenny/features/categories/data/dto/update_category_request.dart';
import 'package:saveapenny/features/categories/domain/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/category.dart';

part 'categories_repository.g.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  const CategoriesRepositoryImpl(this._categoriesApi);

  final CategoriesApi _categoriesApi;

  @override
  Future<List<Category>> list() async {
    final results = await Future.wait(<Future<List<CategoryResponse>>>[
      _categoriesApi.list('INCOME'),
      _categoriesApi.list('EXPENSE'),
    ]);
    return results
        .expand((List<CategoryResponse> list) => list)
        .map((CategoryResponse item) => item.toDomain())
        .toList(growable: false);
  }

  @override
  Future<Category> create({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
  }) async {
    final response = await _categoriesApi.create(
      CreateCategoryRequest(
        name: name,
        type: _categoryTypeToWire(type),
        icon: icon,
        color: color,
      ),
    );

    return response.toDomain();
  }

  @override
  Future<Category> update({
    required String categoryId,
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
  }) async {
    final response = await _categoriesApi.update(
      categoryId: categoryId,
      request: UpdateCategoryRequest(
        name: name,
        type: _categoryTypeToWire(type),
        icon: icon,
        color: color,
      ),
    );

    return response.toDomain();
  }

  @override
  Future<void> delete(String categoryId) {
    return _categoriesApi.delete(categoryId);
  }
}

String _categoryTypeToWire(CategoryType type) {
  return switch (type) {
    CategoryType.income => 'INCOME',
    CategoryType.expense => 'EXPENSE',
  };
}

@Riverpod(keepAlive: true)
CategoriesRepository categoriesRepository(Ref ref) {
  return CategoriesRepositoryImpl(ref.watch(categoriesApiProvider));
}
