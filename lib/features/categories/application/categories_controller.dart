import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/categories/data/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/category.dart';

part 'categories_controller.g.dart';

@Riverpod(keepAlive: true)
class CategoriesController extends _$CategoriesController {
  @override
  Future<List<Category>> build() {
    return ref.read(categoriesRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(categoriesRepositoryProvider).list(),
    );
  }

  Future<void> create({
    required String name,
    String? icon,
    String? color,
    String? parentId,
  }) async {
    final current = state is AsyncData<List<Category>>
        ? (state as AsyncData<List<Category>>).value
        : const <Category>[];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final created = await ref
          .read(categoriesRepositoryProvider)
          .create(name: name, icon: icon, color: color, parentId: parentId);
      return <Category>[...current, created];
    });
  }

  Future<void> updateCategory({
    required String categoryId,
    required String name,
    String? icon,
    String? color,
    String? parentId,
  }) async {
    final current = state is AsyncData<List<Category>>
        ? (state as AsyncData<List<Category>>).value
        : const <Category>[];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = await ref
          .read(categoriesRepositoryProvider)
          .update(
            categoryId: categoryId,
            name: name,
            icon: icon,
            color: color,
            parentId: parentId,
          );
      return current
          .map((Category cat) => cat.id == categoryId ? updated : cat)
          .toList(growable: false);
    });
  }

  Future<void> delete(String categoryId) async {
    final current = state is AsyncData<List<Category>>
        ? (state as AsyncData<List<Category>>).value
        : const <Category>[];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoriesRepositoryProvider).delete(categoryId);
      return current
          .where((Category cat) => cat.id != categoryId)
          .toList(growable: false);
    });
  }
}
