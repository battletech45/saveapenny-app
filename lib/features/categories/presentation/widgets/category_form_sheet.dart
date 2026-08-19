import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/app_dropdown_field.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/categories/domain/category_glyph.dart';
import 'package:saveapenny/features/categories/presentation/widgets/category_glyph_picker.dart';
import 'package:saveapenny/features/categories/presentation/widgets/category_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({super.key, this.existing});

  final Category? existing;

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CategoryType _type;
  late String _icon;
  late String _color;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _type = widget.existing?.type ?? CategoryType.expense;
    _icon = widget.existing?.icon ?? 'category';
    _color = widget.existing?.color ?? categoryColorHexOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final isSubmitting = categoriesState.isLoading;
    final failure = categoriesState.hasError
        ? categoriesState.error as Failure
        : null;

    return AppSheetScaffold(
      title: _isEditing ? l10n.categoriesEditTitle : l10n.categoriesCreateTitle,
      subtitle: _isEditing
          ? l10n.categoriesEditSubtitle
          : l10n.categoriesCreateSubtitle,
      failure: failure == null
          ? null
          : CategorySheetFailureNotice(failure: failure),
      actionBar: AppSheetActionBar(
        primaryLabel: isSubmitting
            ? l10n.commonLoading
            : _isEditing
            ? l10n.categoriesSaveCta
            : l10n.categoriesCreateCta,
        onPrimaryPressed: isSubmitting ? null : _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: l10n.categoriesNameLabel),
              validator: (value) => _validateRequired(l10n, value),
            ),
            if (!_isEditing) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              AppDropdownField<CategoryType>(
                key: ValueKey<CategoryType>(_type),
                label: l10n.categoriesTypeLabel,
                value: _type,
                options: CategoryType.values
                    .map(
                      (type) => AppDropdownOption<CategoryType>(
                        value: type,
                        label: categoryTypeLabel(l10n, type),
                      ),
                    )
                    .toList(growable: false),
                onChanged: isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _type = value;
                          });
                        }
                      },
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            CategoryGlyphPicker(
              selectedIcon: _icon,
              selectedColorHex: _color,
              onIconChanged: isSubmitting
                  ? (_) {}
                  : (value) => setState(() => _icon = value),
              onColorChanged: isSubmitting
                  ? (_) {}
                  : (value) => setState(() => _color = value),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String? _validateRequired(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authRequiredFieldError;
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(categoriesControllerProvider.notifier);
    if (_isEditing) {
      await controller.updateCategory(
        categoryId: widget.existing!.id,
        name: _nameController.text.trim(),
        type: widget.existing!.type,
        icon: _icon,
        color: _color,
      );
    } else {
      await controller.create(
        name: _nameController.text.trim(),
        type: _type,
        icon: _icon,
        color: _color,
      );
    }

    final state = ref.read(categoriesControllerProvider);
    if (!mounted || state.hasError) {
      return;
    }

    Navigator.of(context).pop();
  }
}
