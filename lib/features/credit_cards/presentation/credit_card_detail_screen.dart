import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/inline_empty_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/presentation/widgets/account_shared.dart';
import 'package:saveapenny/features/credit_cards/application/credit_cards_controller.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_statement.dart';
import 'package:saveapenny/features/credit_cards/presentation/widgets/credit_card_payment_sheet.dart';
import 'package:saveapenny/features/credit_cards/presentation/widgets/credit_card_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class CreditCardDetailScreen extends ConsumerWidget {
  const CreditCardDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accountsState = ref.watch(accountsControllerProvider);
    final statementsState = ref.watch(
      creditCardDetailControllerProvider(accountId),
    );

    final account = _findAccount(readAsyncData(accountsState), accountId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.creditCardDetailTitle),
      ),
      floatingActionButton: account == null
          ? null
          : FloatingActionButton.extended(
              heroTag: 'creditCardPaymentFab',
              onPressed: () => _showPaymentSheet(context, account),
              icon: const Icon(Icons.payments_outlined),
              label: Text(l10n.creditCardMakePaymentCta),
            ),
      body: SafeArea(
        child: accountsState.isLoading && account == null
            ? const LoadingView()
            : account == null
            ? FailureView(
                failure: const Failure.unknown(),
                onRetry: () =>
                    ref.read(accountsControllerProvider.notifier).refresh(),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(
                        creditCardDetailControllerProvider(accountId).notifier,
                      )
                      .refresh();
                  await ref.read(accountsControllerProvider.notifier).refresh();
                },
                child: statementsState.when(
                  data: (data) => _CreditCardDetailBody(
                    account: account,
                    statements: data.statements,
                    hasNext: data.hasNext,
                  ),
                  loading: () => const LoadingView(),
                  error: (error, _) => FailureView(
                    failure: error as Failure,
                    onRetry: () => ref
                        .read(
                          creditCardDetailControllerProvider(
                            accountId,
                          ).notifier,
                        )
                        .refresh(),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _showPaymentSheet(BuildContext context, Account account) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => CreditCardPaymentSheet(creditAccount: account),
    );
  }

  Account? _findAccount(List<Account>? accounts, String accountId) {
    if (accounts == null) {
      return null;
    }
    for (final account in accounts) {
      if (account.id == accountId) {
        return account;
      }
    }
    return null;
  }
}

class _CreditCardDetailBody extends ConsumerWidget {
  const _CreditCardDetailBody({
    required this.account,
    required this.statements,
    required this.hasNext,
  });

  final Account account;
  final List<CreditCardStatement> statements;
  final bool hasNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final creditCard = account.creditCard;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (hasNext &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          unawaited(
            ref
                .read(creditCardDetailControllerProvider(account.id).notifier)
                .loadMore(),
          );
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          if (creditCard != null)
            _CreditCardSummaryCard(creditCard: creditCard),
          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.creditCardStatementsTitle, style: context.textTheme.title),
          const SizedBox(height: AppSpacing.lg),
          if (statements.isEmpty)
            InlineEmptyView(
              title: l10n.creditCardStatementsEmptyTitle,
              message: l10n.creditCardStatementsEmptyMessage,
            )
          else
            ...statements.map(
              (statement) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _StatementTile(statement: statement, account: account),
              ),
            ),
        ],
      ),
    );
  }
}

class _CreditCardSummaryCard extends StatelessWidget {
  const _CreditCardSummaryCard({required this.creditCard});

  final CreditCardSummary creditCard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SummaryRow(
              label: l10n.creditCardSummaryLimitLabel,
              value: creditCard.creditLimit.toString(),
            ),
            _SummaryRow(
              label: l10n.creditCardSummaryAprLabel,
              value: '${creditCard.apr}%',
            ),
            _SummaryRow(
              label: l10n.creditCardSummaryStatementDayLabel,
              value: creditCard.statementDay.toString(),
            ),
            _SummaryRow(
              label: l10n.creditCardSummaryBalanceLabel,
              value:
                  creditCard.currentStatementBalance?.toString() ??
                  l10n.accountsPaymentDueNoneValue,
            ),
            _SummaryRow(
              label: l10n.creditCardSummaryMinimumDueLabel,
              value:
                  creditCard.minimumPaymentDue?.toString() ??
                  l10n.accountsPaymentDueNoneValue,
            ),
            _SummaryRow(
              label: l10n.creditCardSummaryDueDateLabel,
              value: creditCard.paymentDueDate == null
                  ? l10n.accountsPaymentDueNoneValue
                  : formatCreditCardDate(context, creditCard.paymentDueDate!),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: context.textTheme.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          Text(value, style: context.textTheme.body),
        ],
      ),
    );
  }
}

class _StatementTile extends StatelessWidget {
  const _StatementTile({required this.statement, required this.account});

  final CreditCardStatement statement;
  final Account account;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final newBalance = MoneyFormatter.format(
      context: context,
      amount: statement.newBalance,
      currencyCode: account.currency,
      isDebt: true,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  formatCreditCardDate(context, statement.statementDate),
                  style: context.textTheme.body,
                ),
                AccountInfoPill(
                  label: l10n.accountsStatusLabel,
                  value: statementStatusLabel(l10n, statement.status),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: l10n.creditCardSummaryDueDateLabel,
              value: formatCreditCardDate(context, statement.dueDate),
            ),
            _SummaryRow(
              label: l10n.creditCardSummaryBalanceLabel,
              value: newBalance.text,
            ),
            _SummaryRow(
              label: l10n.creditCardSummaryMinimumDueLabel,
              value: statement.minimumPaymentDue.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
