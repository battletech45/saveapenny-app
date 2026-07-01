import 'package:saveapenny/features/categories/domain/category.dart';

abstract interface class CategoriesRepository {
  Future<List<Category>> list();

  Future<Category> create({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
  });

  Future<Category> update({
    required String categoryId,
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
  });

  Future<void> delete(String categoryId);
}
