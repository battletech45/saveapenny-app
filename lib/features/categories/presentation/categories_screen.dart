import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesState = ref.watch(categoriesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategorySheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.categoriesAddCta),
      ),
      body: SafeArea(
        child: categoriesState.when(
          data: (categories) {
            final systemCategories = categories
                .where((c) => c.type == CategoryType.system)
                .toList(growable: false);
            final userCategories = categories
                .where((c) => c.type == CategoryType.user)
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
                    _SectionHeader(label: l10n.categoriesSystemSection),
                    const SizedBox(height: AppSpacing.sm),
                    ...systemCategories.map(
                      (cat) => _CategoryTile(category: cat),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  if (userCategories.isNotEmpty) ...<Widget>[
                    _SectionHeader(label: l10n.categoriesUserSection),
                    const SizedBox(height: AppSpacing.sm),
                    ...userCategories.map(
                      (cat) => _CategoryTile(
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
            failure: error as Failure,
            onRetry: () =>
                ref.read(categoriesControllerProvider.notifier).refresh(),
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
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        label,
        style: context.textTheme.label.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, this.onEdit, this.onDelete});

  final Category category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              _CategoryIcon(icon: category.icon, color: category.color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(category.name, style: context.textTheme.body),
                    if (category.type == CategoryType.system)
                      Text(
                        l10n.categoriesSystemBadge,
                        style: context.textTheme.label.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: l10n.categoriesDeleteCta,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({this.icon, this.color});

  final String? icon;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final iconData = _parseIcon(icon);
    final bgColor = color != null
        ? _parseColor(color!)
        : context.colors.surfaceSubtle;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: SizedBox(
        width: AppSpacing.huge,
        height: AppSpacing.huge,
        child: Center(child: Icon(iconData, size: 20, color: bgColor)),
      ),
    );
  }

  IconData _parseIcon(String? iconName) {
    return switch (iconName?.toLowerCase()) {
      'shopping' => Icons.shopping_bag_outlined,
      'food' || 'restaurant' => Icons.restaurant_outlined,
      'transport' || 'car' => Icons.directions_car_outlined,
      'home' || 'housing' => Icons.home_outlined,
      'entertainment' => Icons.movie_outlined,
      'health' || 'medical' => Icons.medical_services_outlined,
      'education' => Icons.school_outlined,
      'salary' || 'income' => Icons.trending_up_rounded,
      'savings' || 'investment' => Icons.account_balance_outlined,
      'bills' || 'utilities' => Icons.receipt_long_outlined,
      'travel' => Icons.flight_outlined,
      'shopping_bag' => Icons.shopping_bag_outlined,
      _ => Icons.category_outlined,
    };
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) {
      buffer.write('FF');
      buffer.write(hex.substring(1));
    } else {
      buffer.write('FF$hex');
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
