import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: context.textTheme.label.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Text(value, style: context.textTheme.body)),
      ],
    );
  }
}

class SectionLoadingCard extends StatelessWidget {
  const SectionLoadingCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  AppLocalizations.of(context).commonLoading,
                  style: context.textTheme.body.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String formatStockDate(BuildContext context, DateTime value) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String stockFailureMessage(BuildContext context, Failure failure) {
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
        ApiErrorCode.invalidStockSymbol => l10n.stocksInvalidSymbolError,
        ApiErrorCode.stockQuoteNotAvailable => l10n.stocksQuoteUnavailableError,
        ApiErrorCode.stockHoldingNotFound =>
          l10n.failureResourceNotFoundMessage,
        ApiErrorCode.duplicateStockHolding => l10n.stocksDuplicateHoldingError,
        ApiErrorCode.stockProviderError => l10n.stocksProviderError,
        ApiErrorCode.validationFailed =>
          details.isNotEmpty
              ? details.first
              : l10n.failureValidationFailedMessage,
        _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
        _ => message.isNotEmpty ? message : l10n.failureValidationFailedMessage,
      },
  };
}
