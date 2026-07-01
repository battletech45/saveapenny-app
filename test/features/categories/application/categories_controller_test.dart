import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/data/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/category.dart';

class _FakeCategoriesRepository implements CategoriesRepository {
  _FakeCategoriesRepository({this.onList, this.onCreate});

  final Future<List<Category>> Function()? onList;
  final Future<Category> Function(
    String name,
    String? icon,
    String? color,
    String? parentId,
  )?
  onCreate;

  @override
  Future<Category> create({
    required String name,
    String? icon,
    String? color,
    String? parentId,
  }) {
    return onCreate!(name, icon, color, parentId);
  }

  @override
  Future<void> delete(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> list() {
    return onList!();
  }

  @override
  Future<Category> update({
    required String categoryId,
    required String name,
    String? icon,
    String? color,
    String? parentId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('create appends a new category to the current state', () async {
    final existing = Category(
      id: 'c-1',
      name: 'Groceries',
      type: CategoryType.system,
      active: true,
      createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
      updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
    );
    final created = existing.copyWith(
      id: 'c-2',
      name: 'Hobbies',
      type: CategoryType.user,
    );

    final container = ProviderContainer(
      overrides: [
        categoriesRepositoryProvider.overrideWith(
          (ref) => _FakeCategoriesRepository(
            onList: () async => <Category>[existing],
            onCreate: (name, icon, color, parentId) async => created,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(categoriesControllerProvider.future);
    await container
        .read(categoriesControllerProvider.notifier)
        .create(name: 'Hobbies');

    expect(container.read(categoriesControllerProvider).value, <Category>[
      existing,
      created,
    ]);
  });

  test('create exposes the primary validation failure path', () async {
    final container = ProviderContainer(
      overrides: [
        categoriesRepositoryProvider.overrideWith(
          (ref) => _FakeCategoriesRepository(
            onList: () async => const <Category>[],
            onCreate: (name, icon, color, parentId) async {
              throw const Failure.api(
                code: ApiErrorCode.validationFailed,
                message: 'Invalid category',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(categoriesControllerProvider.future);
    await container
        .read(categoriesControllerProvider.notifier)
        .create(name: '');

    expect(container.read(categoriesControllerProvider).hasError, isTrue);
  });
}
