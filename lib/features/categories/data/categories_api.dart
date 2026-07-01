import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/categories/data/dto/category_response.dart';
import 'package:saveapenny/features/categories/data/dto/create_category_request.dart';
import 'package:saveapenny/features/categories/data/dto/update_category_request.dart';

part 'categories_api.g.dart';

class CategoriesApi {
  const CategoriesApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CategoryResponse>> list(String type) {
    return _apiClient.send<List<CategoryResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/categories',
        queryParameters: <String, String>{'type': type},
      ),
      fromData: (data) {
        final items = data as List<Object?>;
        return items
            .map((item) => CategoryResponse.fromJson(_readJsonMap(item)))
            .toList(growable: false);
      },
    );
  }

  Future<CategoryResponse> create(CreateCategoryRequest request) {
    return _apiClient.send<CategoryResponse>(
      call: (dio) => dio.post<dynamic>('/categories', data: request.toJson()),
      fromData: (data) => CategoryResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<CategoryResponse> update({
    required String categoryId,
    required UpdateCategoryRequest request,
  }) {
    return _apiClient.send<CategoryResponse>(
      call: (dio) =>
          dio.put<dynamic>('/categories/$categoryId', data: request.toJson()),
      fromData: (data) => CategoryResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> delete(String categoryId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>('/categories/$categoryId'),
      fromData: (_) {},
    );
  }
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
CategoriesApi categoriesApi(Ref ref) {
  return CategoriesApi(ref.watch(apiClientProvider));
}
