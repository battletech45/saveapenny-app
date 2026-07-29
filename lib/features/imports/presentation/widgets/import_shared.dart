import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String importFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      ApiErrorCode.invalidImportFile => l10n.importsInvalidFileError,
      ApiErrorCode.importNotFound => l10n.failureResourceNotFoundMessage,
      ApiErrorCode.importAlreadyRunning => l10n.importsAlreadyRunningError,
      _ => l10n.failureValidationFailedMessage,
    },
  };
}

class ImportErrorNotice extends StatelessWidget {
  const ImportErrorNotice({super.key, required this.failure});

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
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: context.finance.expense,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                importFailureMessage(context, failure),
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImportSummaryCard extends StatelessWidget {
  const ImportSummaryCard({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData? icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, color: context.colors.textSecondary),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(child: Text(label, style: context.textTheme.body)),
            Text(
              value,
              style: context.textTheme.title.copyWith(
                color: valueColor ?? context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
