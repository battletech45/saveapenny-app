import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class UpcomingBillsList extends StatelessWidget {
  const UpcomingBillsList({super.key, required this.bills});

  final List<UpcomingRecurringTransaction> bills;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Card(
      child: Column(
        children: <Widget>[
          for (final bill in bills)
            ListTile(
              onTap: () => unawaited(
                GoRouter.of(context).push('/recurring-transactions'),
              ),
              leading: Builder(
                builder: (context) {
                  final daysUntil = bill.scheduledDate
                      .difference(DateTime.now())
                      .inDays;
                  final urgent = daysUntil <= 3;
                  final color = urgent
                      ? context.finance.warning
                      : context.finance.info;
                  return CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(Icons.event_repeat_rounded, color: color),
                  );
                },
              ),
              title: Text(
                bill.name ?? l10n.recurringTransactionUnnamed,
                style: context.textTheme.body,
              ),
              subtitle: Text(
                dateFormat.format(bill.scheduledDate),
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              trailing: Text(
                MoneyFormatter.format(
                  context: context,
                  amount: -bill.amount,
                  currencyCode: 'TRY',
                ).text,
                style: context.textTheme.money.copyWith(
                  color: context.finance.expense,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
