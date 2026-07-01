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
    final page = await _categoriesApi.list();
    return page.items
        .map((CategoryResponse item) => item.toDomain())
        .toList(growable: false);
  }

  @override
  Future<Category> create({
    required String name,
    String? icon,
    String? color,
    String? parentId,
  }) async {
    final response = await _categoriesApi.create(
      CreateCategoryRequest(
        name: name,
        icon: icon,
        color: color,
        parentId: parentId,
      ),
    );

    return response.toDomain();
  }

  @override
  Future<Category> update({
    required String categoryId,
    required String name,
    String? icon,
    String? color,
    String? parentId,
  }) async {
    final response = await _categoriesApi.update(
      categoryId: categoryId,
      request: UpdateCategoryRequest(
        name: name,
        icon: icon,
        color: color,
        parentId: parentId,
      ),
    );

    return response.toDomain();
  }

  @override
  Future<void> delete(String categoryId) {
    return _categoriesApi.delete(categoryId);
  }
}

@Riverpod(keepAlive: true)
CategoriesRepository categoriesRepository(Ref ref) {
  return CategoriesRepositoryImpl(ref.watch(categoriesApiProvider));
}
