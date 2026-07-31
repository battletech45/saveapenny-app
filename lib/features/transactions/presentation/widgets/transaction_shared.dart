import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String transactionTypeLabel(AppLocalizations l10n, TransactionType type) {
  return switch (type) {
    TransactionType.income => l10n.transactionsTypeIncome,
    TransactionType.expense => l10n.transactionsTypeExpense,
    TransactionType.transfer => l10n.transactionsTypeTransfer,
  };
}

String transactionFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
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
}

T? readTransactionsAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
