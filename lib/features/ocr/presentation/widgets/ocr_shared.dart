import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String ocrStatusLabel(BuildContext context, OcrJobStatus status) {
  final l10n = AppLocalizations.of(context);

  return switch (status) {
    OcrJobStatus.pending => l10n.ocrStatusPending,
    OcrJobStatus.running => l10n.ocrStatusRunning,
    OcrJobStatus.completed => l10n.ocrStatusCompleted,
    OcrJobStatus.failed => l10n.ocrStatusFailed,
  };
}

class OcrStatusPill extends StatelessWidget {
  const OcrStatusPill({super.key, required this.status});

  final OcrJobStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      OcrJobStatus.pending || OcrJobStatus.running => (
        context.finance.warningSurface,
        context.finance.warning,
      ),
      OcrJobStatus.completed => (
        context.finance.incomeSurface,
        context.finance.income,
      ),
      OcrJobStatus.failed => (
        context.finance.expenseSurface,
        context.finance.expense,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          ocrStatusLabel(context, status),
          style: context.textTheme.label.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class OcrInfoRow extends StatelessWidget {
  const OcrInfoRow({super.key, required this.label, required this.value});

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

class OcrInlineEmptyState extends StatelessWidget {
  const OcrInlineEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String ocrFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      ApiErrorCode.invalidOcrFile => l10n.ocrInvalidFileError,
      ApiErrorCode.ocrJobNotFound => l10n.failureResourceNotFoundMessage,
      ApiErrorCode.ocrProcessingFailed => l10n.ocrProcessingFailedError,
      _ => l10n.failureValidationFailedMessage,
    },
  };
}

class OcrErrorNotice extends StatelessWidget {
  const OcrErrorNotice({super.key, required this.failure, this.customMessage});

  final Failure failure;
  final String? customMessage;

  @override
  Widget build(BuildContext context) {
    final message = customMessage ?? ocrFailureMessage(context, failure);

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
                message,
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
