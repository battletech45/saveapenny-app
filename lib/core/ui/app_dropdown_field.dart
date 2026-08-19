import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';

class AppDropdownOption<T> {
  const AppDropdownOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
    this.validator,
    this.enabled = true,
    super.key,
  });

  final String label;
  final T? value;
  final List<AppDropdownOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        final selectedOption = _selectedOption(field.value);
        final interactive = enabled && onChanged != null && options.isNotEmpty;

        return InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: interactive
              ? () async {
                  FocusScope.of(context).unfocus();
                  final result =
                      await showAppModalBottomSheet<_DropdownResult<T>>(
                        context: context,
                        builder: (context) => _AppDropdownSheet<T>(
                          title: label,
                          options: options,
                          selectedValue: field.value,
                        ),
                      );
                  if (result == null) {
                    return;
                  }
                  field.didChange(result.value);
                  onChanged?.call(result.value);
                }
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: field.errorText,
              enabled: interactive,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    selectedOption?.label ?? hint ?? '',
                    style: context.textTheme.body.copyWith(
                      color: selectedOption == null
                          ? context.colors.textTertiary
                          : context.colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: interactive
                      ? context.colors.textSecondary
                      : context.colors.textTertiary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppDropdownOption<T>? _selectedOption(T? currentValue) {
    for (final option in options) {
      if (option.value == currentValue) {
        return option;
      }
    }
    return null;
  }
}

class _DropdownResult<T> {
  const _DropdownResult(this.value);

  final T value;
}

class _AppDropdownSheet<T> extends StatelessWidget {
  const _AppDropdownSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
  });

  final String title;
  final List<AppDropdownOption<T>> options;
  final T? selectedValue;

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: title,
      showCloseButton: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final option in options)
              _AppDropdownOptionTile<T>(
                option: option,
                selected: option.value == selectedValue,
              ),
          ],
        ),
      ),
    );
  }
}

class _AppDropdownOptionTile<T> extends StatelessWidget {
  const _AppDropdownOptionTile({required this.option, required this.selected});

  final AppDropdownOption<T> option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: context.colors.border),
        ),
        child: ListTile(
          enabled: option.enabled,
          leading: option.icon == null ? null : Icon(option.icon),
          title: Text(option.label, style: context.textTheme.body),
          subtitle: option.subtitle == null
              ? null
              : Text(
                  option.subtitle!,
                  style: context.textTheme.label.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
          trailing: Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : context.colors.textTertiary,
          ),
          onTap: option.enabled
              ? () =>
                    Navigator.of(context).pop(_DropdownResult<T>(option.value))
              : null,
        ),
      ),
    );
  }
}
