import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String? validateRequiredSelection(AppLocalizations l10n, String? value) {
  if (value == null || value.isEmpty) {
    return l10n.authRequiredFieldError;
  }

  return null;
}

String? validateAmount(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) {
    return l10n.authRequiredFieldError;
  }

  final amount = num.tryParse(value.trim());
  if (amount == null || amount <= 0) {
    return l10n.transactionsAmountError;
  }

  return null;
}

Future<DateTime?> showTransactionDatePicker(
  BuildContext context,
  DateTime initialDate,
) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}

CategoryType categoryTypeFor(TransactionType type) {
  return switch (type) {
    TransactionType.income => CategoryType.income,
    TransactionType.expense || TransactionType.transfer => CategoryType.expense,
  };
}

Account? selectedAccountById(List<Account> accounts, String? accountId) {
  for (final account in accounts) {
    if (account.id == accountId) {
      return account;
    }
  }

  return null;
}

String resolveTransferCurrency({
  required Account? fromAccount,
  required Account? toAccount,
}) {
  if (fromAccount == null) {
    return '';
  }
  if (toAccount == null || fromAccount.currency == toAccount.currency) {
    return fromAccount.currency;
  }
  return '${fromAccount.currency} / ${toAccount.currency}';
}

String withFallback(String value, String fallback) {
  return value.isEmpty ? fallback : value;
}

T? readAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}

class TransactionsSheetFailureNotice extends StatelessWidget {
  const TransactionsSheetFailureNotice({required this.failure, super.key});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (failure) {
      NetworkFailure() => l10n.failureNetworkMessage,
      UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
      RateLimitedFailure() => l10n.failureRateLimitedMessage,
      UnknownFailure() => l10n.failureGenericMessage,
      ApiFailure(code: final code) => switch (code) {
        ApiErrorCode.insufficientBalance =>
          l10n.transactionsInsufficientBalanceError,
        ApiErrorCode.invalidTransfer => l10n.transactionsInvalidTransferError,
        ApiErrorCode.invalidTransactionCurrency =>
          l10n.transactionsCurrencyMismatchError,
        ApiErrorCode.transactionNotFound => l10n.failureResourceNotFoundMessage,
        _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
        _ => l10n.failureValidationFailedMessage,
      },
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.finance.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          message,
          style: context.textTheme.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class TransactionsReadOnlyField extends StatelessWidget {
  const TransactionsReadOnlyField({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value, style: context.textTheme.body),
    );
  }
}

class TransactionsReadOnlyActionField extends StatelessWidget {
  const TransactionsReadOnlyActionField({
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onPressed,
    super.key,
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
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, AppSpacing.giant),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
