import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool showDragHandle = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: context.colors.surface,
    clipBehavior: Clip.antiAlias,
    isScrollControlled: isScrollControlled,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    showDragHandle: showDragHandle,
    useRootNavigator: useRootNavigator,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
    ),
    builder: builder,
  );
}

class AppSheetScaffold extends StatelessWidget {
  const AppSheetScaffold({
    required this.title,
    required this.child,
    this.subtitle,
    this.failure,
    this.actionBar,
    this.showCloseButton = true,
    this.scrollable = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? failure;
  final Widget child;
  final AppSheetActionBar? actionBar;
  final bool showCloseButton;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: child,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppSheetHeader(
              title: title,
              subtitle: subtitle,
              showCloseButton: showCloseButton,
            ),
            if (failure != null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: failure,
              ),
            ],
            Flexible(
              child: scrollable ? SingleChildScrollView(child: body) : body,
            ),
            ?actionBar,
          ],
        ),
      ),
    );
  }
}

class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    required this.title,
    this.subtitle,
    this.showCloseButton = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: context.textTheme.title),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle!,
                    style: context.textTheme.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showCloseButton) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            IconButton.filledTonal(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ],
      ),
    );
  }
}

class AppSheetActionBar extends StatelessWidget {
  const AppSheetActionBar({
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
    super.key,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (secondaryLabel != null) ...<Widget>[
              TextButton(
                onPressed: onSecondaryPressed,
                child: Text(secondaryLabel!),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            ElevatedButton(
              onPressed: onPrimaryPressed,
              child: Text(primaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSelectionOption<T> {
  const AppSelectionOption({required this.value, required this.label});

  final T value;
  final String label;
}

class AppSelectionSheet<T> extends StatelessWidget {
  const AppSelectionSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    super.key,
  });

  final String title;
  final List<AppSelectionOption<T>> options;
  final T selectedValue;
  final Future<void> Function(T value) onSelected;

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
              _AppSelectionTile<T>(
                option: option,
                selected: option.value == selectedValue,
                onSelected: onSelected,
              ),
          ],
        ),
      ),
    );
  }
}

class _AppSelectionTile<T> extends StatelessWidget {
  const _AppSelectionTile({
    required this.option,
    required this.selected,
    required this.onSelected,
  });

  final AppSelectionOption<T> option;
  final bool selected;
  final Future<void> Function(T value) onSelected;

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
          title: Text(option.label, style: context.textTheme.body),
          trailing: Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : context.colors.textTertiary,
          ),
          onTap: () async {
            await onSelected(option.value);
            if (context.mounted) {
              Navigator.of(context).pop(option.value);
            }
          },
        ),
      ),
    );
  }
}
