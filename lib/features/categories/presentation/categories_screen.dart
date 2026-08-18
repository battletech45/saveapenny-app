import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/core/ui/scroll_aware_fab.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:saveapenny/features/categories/presentation/widgets/category_tile.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesState = ref.watch(categoriesControllerProvider);

    return ScrollAwareFabVisibility(
      builder: (context, fabVisible) => Scaffold(
        appBar: AppBar(title: Text(l10n.categoriesTitle)),
        floatingActionButton: ScrollAwareFab(
          visible: fabVisible,
          child: FloatingActionButton.extended(
            heroTag: 'categoriesFab',
            onPressed: () => _showCategorySheet(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.categoriesAddCta),
          ),
        ),
        body: SafeArea(
          child: categoriesState.when(
            data: (categories) {
              final systemCategories = categories
                  .where((c) => c.userId == null)
                  .toList(growable: false);
              final userCategories = categories
                  .where((c) => c.userId != null)
                  .toList(growable: false);

              if (categories.isEmpty) {
                return EmptyView(
                  title: l10n.categoriesEmptyTitle,
                  message: l10n.categoriesEmptyMessage,
                  action: ElevatedButton(
                    onPressed: () => _showCategorySheet(context, ref),
                    child: Text(l10n.categoriesAddFirstCta),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(categoriesControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: <Widget>[
                    if (systemCategories.isNotEmpty) ...<Widget>[
                      CategorySectionHeader(
                        label: l10n.categoriesSystemSection,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...systemCategories.map(
                        (cat) => CategoryTile(category: cat),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    if (userCategories.isNotEmpty) ...<Widget>[
                      CategorySectionHeader(label: l10n.categoriesUserSection),
                      const SizedBox(height: AppSpacing.sm),
                      ...userCategories.map(
                        (cat) => CategoryTile(
                          category: cat,
                          onEdit: () =>
                              _showCategorySheet(context, ref, existing: cat),
                          onDelete: () => _confirmDelete(context, ref, cat),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            loading: () => const LoadingView(),
            error: (error, _) => FailureView(
              failure: error is Failure
                  ? error
                  : Failure.unknown(message: error.toString()),
              onRetry: () =>
                  ref.read(categoriesControllerProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCategorySheet(
    BuildContext context,
    WidgetRef ref, {
    Category? existing,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => CategoryFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.categoriesDeleteTitle),
          content: Text(l10n.categoriesDeleteMessage(category.name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.categoriesDeleteCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(categoriesControllerProvider.notifier).delete(category.id);
  }
}
