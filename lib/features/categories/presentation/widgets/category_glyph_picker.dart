import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/categories/domain/category_glyph.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

/// A grid of selectable icons and swatches for the category create/edit
/// form, so `Category.icon`/`Category.color` can actually be set from the
/// client instead of only ever arriving pre-populated from the backend.
class CategoryGlyphPicker extends StatelessWidget {
  const CategoryGlyphPicker({
    super.key,
    required this.selectedIcon,
    required this.selectedColorHex,
    required this.onIconChanged,
    required this.onColorChanged,
  });

  final String selectedIcon;
  final String selectedColorHex;
  final ValueChanged<String> onIconChanged;
  final ValueChanged<String> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedColor = parseCategoryColor(selectedColorHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.categoriesIconLabel, style: context.textTheme.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final entry in categoryIconOptions.entries)
              _GlyphOption(
                selected: entry.key == selectedIcon,
                color: selectedColor,
                onTap: () => onIconChanged(entry.key),
                child: Icon(entry.value, size: 20),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.categoriesColorLabel, style: context.textTheme.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final hex in categoryColorHexOptions)
              _GlyphOption(
                selected: hex.toUpperCase() == selectedColorHex.toUpperCase(),
                color: parseCategoryColor(hex),
                onTap: () => onColorChanged(hex),
                child: const SizedBox.shrink(),
              ),
          ],
        ),
      ],
    );
  }
}

class _GlyphOption extends StatelessWidget {
  const _GlyphOption({
    required this.selected,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        width: AppSpacing.huge,
        height: AppSpacing.huge,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: selected ? Border.all(color: color, width: 2) : null,
        ),
        child: Center(
          child: IconTheme.merge(
            data: IconThemeData(color: color),
            child: child,
          ),
        ),
      ),
    );
  }
}
