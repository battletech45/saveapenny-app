import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AuthFormShell extends StatelessWidget {
  const AuthFormShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
    this.failure,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;
  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.huge),
                  Text(title, style: context.textTheme.headline),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: context.textTheme.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (failure != null) ...<Widget>[
                            _AuthFailureNotice(
                              title: l10n.authFormErrorTitle,
                              message: _failureMessage(l10n, failure!),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          form,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  footer,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, Failure failure) {
    return switch (failure) {
      NetworkFailure() => l10n.failureNetworkMessage,
      UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
      RateLimitedFailure() => l10n.failureRateLimitedMessage,
      UnknownFailure() => l10n.failureGenericMessage,
      ApiFailure(code: final code) => switch (code) {
        _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
        ApiErrorCode.invalidPassword => l10n.failureInvalidPasswordMessage,
        ApiErrorCode.invalidCredentials =>
          l10n.failureInvalidCredentialsMessage,
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
}

class _AuthFailureNotice extends StatelessWidget {
  const _AuthFailureNotice({required this.title, required this.message});

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
