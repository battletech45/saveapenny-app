import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final copy = _localizedCopy(l10n);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: context.finance.expense,
              size: AppSpacing.giant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              copy.title,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              copy.message,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await onRetry!();
                  },
                  child: Text(l10n.commonRetry),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _FailureCopy _localizedCopy(AppLocalizations l10n) {
    return failure.map(
      network: (_) => _FailureCopy(
        title: l10n.failureNetworkTitle,
        message: l10n.failureNetworkMessage,
      ),
      unauthenticated: (_) => _FailureCopy(
        title: l10n.failureUnauthenticatedTitle,
        message: l10n.failureUnauthenticatedMessage,
      ),
      rateLimited: (_) => _FailureCopy(
        title: l10n.failureRateLimitedTitle,
        message: l10n.failureRateLimitedMessage,
      ),
      unknown: (_) => _FailureCopy(
        title: l10n.failureGenericTitle,
        message: l10n.failureGenericMessage,
      ),
      api: (failure) => _apiFailureCopy(l10n, failure.code),
    );
  }

  _FailureCopy _apiFailureCopy(AppLocalizations l10n, ApiErrorCode code) {
    return switch (code) {
      ApiErrorCode.validationFailed => _FailureCopy(
        title: l10n.failureValidationFailedTitle,
        message: l10n.failureValidationFailedMessage,
      ),
      ApiErrorCode.invalidPassword => _FailureCopy(
        title: l10n.failureInvalidPasswordTitle,
        message: l10n.failureInvalidPasswordMessage,
      ),
      ApiErrorCode.invalidCredentials => _FailureCopy(
        title: l10n.failureInvalidCredentialsTitle,
        message: l10n.failureInvalidCredentialsMessage,
      ),
      ApiErrorCode.resourceNotFound ||
      ApiErrorCode.userNotFound ||
      ApiErrorCode.accountNotFound ||
      ApiErrorCode.categoryNotFound ||
      ApiErrorCode.transactionNotFound => _FailureCopy(
        title: l10n.failureResourceNotFoundTitle,
        message: l10n.failureResourceNotFoundMessage,
      ),
      _ when code.isFeatureDisabled => _FailureCopy(
        title: l10n.failureFeatureDisabledTitle,
        message: l10n.failureFeatureDisabledMessage,
      ),
      _ => _FailureCopy(
        title: l10n.failureGenericTitle,
        message: l10n.failureGenericMessage,
      ),
    };
  }
}

class _FailureCopy {
  const _FailureCopy({required this.title, required this.message});

  final String title;
  final String message;
}
