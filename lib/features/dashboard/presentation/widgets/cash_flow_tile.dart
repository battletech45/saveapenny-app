import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/animated_money.dart';

class CashFlowTile extends StatelessWidget {
  const CashFlowTile({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final num amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: AppSpacing.lg,
                  color: context.finance.forAmount(amount),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    label,
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedMoney(
                amount: amount,
                currencyCode: 'TRY',
                style: context.textTheme.money,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
