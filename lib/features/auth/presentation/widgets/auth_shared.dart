import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AuthFailureNotice extends StatelessWidget {
  const AuthFailureNotice({
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
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.finance.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: context.textTheme.body.copyWith(
                color: context.colors.textPrimary,
                fontWeight: AppFontWeight.semibold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        children: <Widget>[
          Text(
            prompt,
            style: context.textTheme.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

String authFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure(code: final code) => switch (code) {
      _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
      ApiErrorCode.invalidPassword => l10n.failureInvalidPasswordMessage,
      ApiErrorCode.passwordReuseNotAllowed =>
        l10n.failurePasswordReuseNotAllowedMessage,
      ApiErrorCode.invalidCredentials => l10n.failureInvalidCredentialsMessage,
      ApiErrorCode.validationFailed => l10n.failureValidationFailedMessage,
      ApiErrorCode.resourceNotFound ||
      ApiErrorCode.userNotFound ||
      ApiErrorCode.accountNotFound ||
      ApiErrorCode.categoryNotFound ||
      ApiErrorCode.transactionNotFound => l10n.failureResourceNotFoundMessage,
      _ => l10n.failureGenericMessage,
    },
  };
}

String? validateRequired(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) {
    return l10n.authRequiredFieldError;
  }

  return null;
}

String? validateEmail(AppLocalizations l10n, String? value) {
  final requiredError = validateRequired(l10n, value);
  if (requiredError != null) {
    return requiredError;
  }

  final trimmed = value!.trim();
  if (!trimmed.contains('@') || !trimmed.contains('.')) {
    return l10n.authInvalidEmailError;
  }

  return null;
}
