import 'package:saveapenny/features/categories/domain/category.dart';

abstract interface class CategoriesRepository {
  Future<List<Category>> list();

  Future<Category> create({
    required String name,
    String? icon,
    String? color,
    String? parentId,
  });

  Future<Category> update({
    required String categoryId,
    required String name,
    String? icon,
    String? color,
    String? parentId,
  });

  Future<void> delete(String categoryId);
}
