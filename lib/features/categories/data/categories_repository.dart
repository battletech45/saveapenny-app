import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/cached_fetch.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';
import 'package:saveapenny/features/categories/data/categories_api.dart';
import 'package:saveapenny/features/categories/data/dto/category_response.dart';
import 'package:saveapenny/features/categories/data/dto/create_category_request.dart';
import 'package:saveapenny/features/categories/data/dto/update_category_request.dart';
import 'package:saveapenny/features/categories/domain/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/category.dart';

part 'categories_repository.g.dart';

const String _listCacheKey = 'categories:list';

class CategoriesRepositoryImpl implements CategoriesRepository {
  const CategoriesRepositoryImpl(this._categoriesApi, this._cache);

  final CategoriesApi _categoriesApi;
  final ResponseCacheStore _cache;

  @override
  Future<List<Category>> list() async {
    final items = await cachedFetch<List<CategoryResponse>>(
      cache: _cache,
      key: _listCacheKey,
      call: () async {
        final results = await Future.wait(<Future<List<CategoryResponse>>>[
          _categoriesApi.list('INCOME'),
          _categoriesApi.list('EXPENSE'),
        ]);
        return results
            .expand((List<CategoryResponse> list) => list)
            .toList(growable: false);
      },
      toJson: (items) => <String, dynamic>{
        'items': items.map((item) => item.toJson()).toList(),
      },
      fromJson: (json) => (json['items']! as List<dynamic>)
          .map(
            (item) => CategoryResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
    return items
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
    await _cache.invalidate(_listCacheKey);

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
    await _cache.invalidate(_listCacheKey);

    return response.toDomain();
  }

  @override
  Future<void> delete(String categoryId) async {
    await _categoriesApi.delete(categoryId);
    await _cache.invalidate(_listCacheKey);
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
  return CategoriesRepositoryImpl(
    ref.watch(categoriesApiProvider),
    ref.watch(responseCacheStoreProvider),
  );
}
