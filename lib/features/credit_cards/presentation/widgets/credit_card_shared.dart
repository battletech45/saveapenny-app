import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String statementStatusLabel(AppLocalizations l10n, StatementStatus status) {
  return switch (status) {
    StatementStatus.open => l10n.creditCardStatementStatusOpen,
    StatementStatus.paid => l10n.creditCardStatementStatusPaid,
    StatementStatus.missed => l10n.creditCardStatementStatusMissed,
  };
}

String formatCreditCardDate(BuildContext context, DateTime value) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String creditCardFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure(message: final message) =>
      message != null && message.isNotEmpty
          ? message
          : l10n.failureGenericMessage,
    ApiFailure(
      code: final code,
      message: final message,
      details: final details,
    ) =>
      switch (code) {
        ApiErrorCode.creditLimitExceeded ||
        ApiErrorCode.invalidCreditCardDetails ||
        ApiErrorCode.invalidCreditCardPayment =>
          message.isNotEmpty ? message : l10n.failureValidationFailedMessage,
        ApiErrorCode.creditCardDetailsNotFound ||
        ApiErrorCode.accountNotFound => l10n.failureResourceNotFoundMessage,
        ApiErrorCode.validationFailed =>
          details.isNotEmpty
              ? details.first
              : l10n.failureValidationFailedMessage,
        ApiErrorCode.serverError ||
        ApiErrorCode.internalServerError ||
        ApiErrorCode.serviceUnavailable => l10n.failureGenericMessage,
        _ => message.isNotEmpty ? message : l10n.failureValidationFailedMessage,
      },
  };
}

T? readAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
