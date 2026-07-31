import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String budgetPeriodLabel(AppLocalizations l10n, BudgetPeriod period) {
  return switch (period) {
    BudgetPeriod.monthly => l10n.budgetsPeriodMonthly,
    BudgetPeriod.yearly => l10n.budgetsPeriodYearly,
  };
}

String budgetStatusLabel(AppLocalizations l10n, BudgetHealth status) {
  return switch (status) {
    BudgetHealth.onTrack => l10n.budgetsStatusOnTrack,
    BudgetHealth.warning => l10n.budgetsStatusWarning,
    BudgetHealth.exceeded => l10n.budgetsStatusExceeded,
  };
}

String budgetFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      ApiErrorCode.budgetNotFound => l10n.failureResourceNotFoundMessage,
      ApiErrorCode.budgetAlreadyExists => l10n.budgetsDuplicateError,
      ApiErrorCode.invalidBudgetDateRange => l10n.budgetsDateRangeError,
      _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
      _ => l10n.failureValidationFailedMessage,
    },
  };
}

String formatBudgetDate(BuildContext context, DateTime value) {
  return MaterialLocalizations.of(context).formatMediumDate(value);
}

String formatBudgetRange(BuildContext context, Budget budget) {
  return '${formatBudgetDate(context, budget.startDate)} - ${formatBudgetDate(context, budget.endDate)}';
}

String formatBudgetAmount(BuildContext context, num value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 2,
  ).format(value);
}

Color budgetStatusColor(BuildContext context, BudgetHealth status) {
  return switch (status) {
    BudgetHealth.onTrack => context.colors.textPrimary,
    BudgetHealth.warning => context.finance.warning,
    BudgetHealth.exceeded => context.finance.expense,
  };
}
