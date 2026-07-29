import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: context.textTheme.label.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: context.textTheme.body),
      ],
    );
  }
}

class ProfileSheetFailureNotice extends StatelessWidget {
  const ProfileSheetFailureNotice({super.key, required this.failure});

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
          profileFailureMessage(context, failure),
          style: context.textTheme.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

String profileFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);
  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      ApiErrorCode.invalidPassword => l10n.failureInvalidPasswordMessage,
      ApiErrorCode.passwordReuseNotAllowed =>
        l10n.failurePasswordReuseNotAllowedMessage,
      ApiErrorCode.validationFailed => l10n.failureValidationFailedMessage,
      _ => l10n.failureGenericMessage,
    },
  };
}

String formatProfileDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final date = DateFormat.yMMMd(locale).format(value);
  final time = DateFormat.Hm(locale).format(value);
  return '$date $time';
}
