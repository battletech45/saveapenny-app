import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

/// Standardizes the swipe-to-edit/delete interaction already proven in
/// Notifications/Insights, so it can replace `PopupMenuButton` 3-dot menus
/// across Transactions, Budgets, Accounts, Goals, and Feedback lists.
///
/// Swipe right-to-left reveals delete (required); swipe left-to-right
/// reveals edit (optional — omit [onEdit] to allow delete-only swiping).
class SwipeActionRow extends StatelessWidget {
  const SwipeActionRow({
    super.key,
    required this.itemKey,
    required this.child,
    required this.onDelete,
    this.onEdit,
    this.confirmDelete,
  });

  final Key itemKey;
  final Widget child;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final Future<bool> Function()? confirmDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: onEdit != null
          ? DismissDirection.horizontal
          : DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false;
        }
        if (confirmDelete != null) {
          return confirmDelete!();
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      background: onEdit != null
          ? _ActionBackground(
              alignment: Alignment.centerLeft,
              color: context.finance.info,
              icon: Icons.edit_outlined,
            )
          : const SizedBox.shrink(),
      secondaryBackground: _ActionBackground(
        alignment: Alignment.centerRight,
        color: context.finance.expense,
        icon: Icons.delete_outline_rounded,
      ),
      child: child,
    );
  }
}

class _ActionBackground extends StatelessWidget {
  const _ActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.onError),
    );
  }
}
