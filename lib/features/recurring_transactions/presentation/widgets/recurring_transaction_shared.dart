import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String recurringTransactionTypeLabel(
  AppLocalizations l10n,
  RecurringTransactionType type,
) {
  return switch (type) {
    RecurringTransactionType.income => l10n.recurringTransactionsTypeIncome,
    RecurringTransactionType.expense => l10n.recurringTransactionsTypeExpense,
  };
}

String recurringFrequencyLabel(
  AppLocalizations l10n,
  RecurringFrequency frequency,
) {
  return switch (frequency) {
    RecurringFrequency.daily => l10n.recurringTransactionsFrequencyDaily,
    RecurringFrequency.weekly => l10n.recurringTransactionsFrequencyWeekly,
    RecurringFrequency.monthly => l10n.recurringTransactionsFrequencyMonthly,
    RecurringFrequency.yearly => l10n.recurringTransactionsFrequencyYearly,
  };
}

String recurringStatusLabel(AppLocalizations l10n, RecurringStatus status) {
  return switch (status) {
    RecurringStatus.active => l10n.recurringTransactionsStatusActive,
    RecurringStatus.paused => l10n.recurringTransactionsStatusPaused,
    RecurringStatus.expired => l10n.recurringTransactionsStatusExpired,
    RecurringStatus.failed => l10n.recurringTransactionsStatusFailed,
  };
}

String recurringClassificationLabel(
  AppLocalizations l10n,
  RecurringClassification classification,
) {
  return switch (classification) {
    RecurringClassification.paycheck =>
      l10n.recurringTransactionsClassificationPaycheck,
    RecurringClassification.subscription =>
      l10n.recurringTransactionsClassificationSubscription,
    RecurringClassification.rent =>
      l10n.recurringTransactionsClassificationRent,
    RecurringClassification.utility =>
      l10n.recurringTransactionsClassificationUtility,
    RecurringClassification.loanPayment =>
      l10n.recurringTransactionsClassificationLoanPayment,
    RecurringClassification.savingsContribution =>
      l10n.recurringTransactionsClassificationSavingsContribution,
    RecurringClassification.other =>
      l10n.recurringTransactionsClassificationOther,
  };
}

String recurringHistoryStatusLabel(
  AppLocalizations l10n,
  RecurringExecutionStatus status,
) {
  return switch (status) {
    RecurringExecutionStatus.success =>
      l10n.recurringTransactionsHistorySuccess,
    RecurringExecutionStatus.failed => l10n.recurringTransactionsHistoryFailed,
    RecurringExecutionStatus.skipped =>
      l10n.recurringTransactionsHistorySkipped,
  };
}

Color recurringStatusColor(BuildContext context, RecurringStatus status) {
  return switch (status) {
    RecurringStatus.active => context.finance.income,
    RecurringStatus.paused => context.finance.warning,
    RecurringStatus.expired => context.colors.textTertiary,
    RecurringStatus.failed => context.finance.expense,
  };
}

String recurringFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);
  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      ApiErrorCode.recurringTransactionNotFound =>
        l10n.failureResourceNotFoundMessage,
      ApiErrorCode.recurringTransactionDependencyNotFound =>
        l10n.failureResourceNotFoundMessage,
      ApiErrorCode.invalidRecurringTransactionNextRunDate =>
        l10n.recurringTransactionsNextRunDateError,
      ApiErrorCode.invalidRecurringTransactionType =>
        l10n.recurringTransactionsTypeError,
      ApiErrorCode.invalidRecurringTransactionStatusTransition =>
        l10n.recurringTransactionsStatusTransitionError,
      _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
      _ => l10n.failureValidationFailedMessage,
    },
  };
}

CategoryType recurringCategoryTypeFor(RecurringTransactionType type) {
  return switch (type) {
    RecurringTransactionType.income => CategoryType.income,
    RecurringTransactionType.expense => CategoryType.expense,
  };
}

class RecurringInfoPill extends StatelessWidget {
  const RecurringInfoPill({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: context.textTheme.body.copyWith(
                color: valueColor ?? context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecurringFailureNotice extends StatelessWidget {
  const RecurringFailureNotice({super.key, required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.finance.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          recurringFailureMessage(context, failure),
          style: context.textTheme.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class RecurringRequiredDateField extends StatelessWidget {
  const RecurringRequiredDateField({
    super.key,
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onPressed,
  });

  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(value, style: context.textTheme.body)),
          const SizedBox(width: AppSpacing.md),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(64, AppSpacing.giant),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class RecurringOptionalDateField extends StatelessWidget {
  const RecurringOptionalDateField({
    super.key,
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onPressed,
    required this.onClear,
  });

  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback? onPressed;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(value, style: context.textTheme.body)),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
              tooltip: AppLocalizations.of(context).commonBack,
            ),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(64, AppSpacing.giant),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

T? readRecurringAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
