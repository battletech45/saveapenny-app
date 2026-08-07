import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String feedbackTypeLabel(BuildContext context, FeedbackType type) {
  final l10n = AppLocalizations.of(context);
  return switch (type) {
    FeedbackType.general => l10n.feedbackTypeGeneral,
    FeedbackType.featureRequest => l10n.feedbackTypeFeatureRequest,
    FeedbackType.bugReport => l10n.feedbackTypeBugReport,
  };
}

String feedbackStatusLabel(BuildContext context, FeedbackStatus status) {
  final l10n = AppLocalizations.of(context);
  return switch (status) {
    FeedbackStatus.open => l10n.feedbackStatusOpen,
    FeedbackStatus.inReview => l10n.feedbackStatusInReview,
    FeedbackStatus.resolved => l10n.feedbackStatusResolved,
    FeedbackStatus.rejected => l10n.feedbackStatusRejected,
  };
}

(Color surface, Color foreground) feedbackStatusColors(
  BuildContext context,
  FeedbackStatus status,
) {
  return switch (status) {
    FeedbackStatus.open => (
      context.finance.info.withValues(alpha: 0.12),
      context.finance.info,
    ),
    FeedbackStatus.inReview => (
      context.finance.warningSurface,
      context.finance.warning,
    ),
    FeedbackStatus.resolved => (
      context.finance.incomeSurface,
      context.finance.income,
    ),
    FeedbackStatus.rejected => (
      context.finance.expenseSurface,
      context.finance.expense,
    ),
  };
}

String feedbackFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);
  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      ApiErrorCode.feedbackNotFound => l10n.feedbackNotFoundMessage,
      ApiErrorCode.validationFailed => l10n.failureValidationFailedMessage,
      _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
      _ => l10n.failureGenericMessage,
    },
  };
}

String? validateFeedbackMessage(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) {
    return l10n.authRequiredFieldError;
  }
  if (value.trim().length > 5000) {
    return l10n.feedbackMessageError;
  }

  return null;
}

String formatFeedbackDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final date = DateFormat.yMMMd(locale).format(value);
  final time = DateFormat.Hm(locale).format(value);
  return '$date $time';
}

String feedbackRatingLabel(BuildContext context, int? rating) {
  final l10n = AppLocalizations.of(context);
  if (rating == null) {
    return l10n.feedbackNoRating;
  }

  return l10n.feedbackRatingValue(rating);
}

String formatFeedbackMetadata(Map<String, dynamic>? metadata) {
  if (metadata == null || metadata.isEmpty) {
    return '';
  }

  return const JsonEncoder.withIndent('  ').convert(metadata);
}

T? readFeedbackAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}

class FeedbackStatusBadge extends StatelessWidget {
  const FeedbackStatusBadge({super.key, required this.status});

  final FeedbackStatus status;

  @override
  Widget build(BuildContext context) {
    final (surface, foreground) = feedbackStatusColors(context, status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          feedbackStatusLabel(context, status),
          style: context.textTheme.label.copyWith(
            color: foreground,
            fontWeight: AppFontWeight.semibold,
          ),
        ),
      ),
    );
  }
}

class FeedbackFailureNotice extends StatelessWidget {
  const FeedbackFailureNotice({super.key, required this.failure});

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
          feedbackFailureMessage(context, failure),
          style: context.textTheme.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
