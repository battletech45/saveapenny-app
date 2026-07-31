import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/auth/presentation/widgets/auth_shared.dart';
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
                            AuthFailureNotice(
                              title: l10n.authFormErrorTitle,
                              message: authFailureMessage(context, failure!),
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
}
