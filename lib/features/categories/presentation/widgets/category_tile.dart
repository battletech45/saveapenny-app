import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/categories/domain/category_glyph.dart';
import 'package:saveapenny/features/categories/presentation/widgets/category_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class CategorySectionHeader extends StatelessWidget {
  const CategorySectionHeader({super.key, required this.label});

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

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  final Category category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSystem = category.userId == null;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: isSystem ? null : onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              CategoryIcon(icon: category.icon, color: category.color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(category.name, style: context.textTheme.body),
                    Text(
                      categoryTypeLabel(l10n, category.type),
                      style: context.textTheme.label.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSystem)
                Chip(
                  label: Text(
                    l10n.categoriesSystemBadge,
                    style: context.textTheme.label,
                  ),
                ),
              if (!isSystem && onDelete != null)
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

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, this.icon, this.color});

  final String? icon;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final iconData = parseCategoryIcon(icon);
    final bgColor = color != null
        ? parseCategoryColor(color!)
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
}
