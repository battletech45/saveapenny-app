import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.isLast,
    required this.onSkip,
    required this.onContinue,
  });

  final int pageCount;
  final int currentPage;
  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (var i = 0; i < pageCount; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  width: i == currentPage ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == currentPage
                        ? context.colors.textPrimary
                        : context.colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: <Widget>[
              if (!isLast)
                TextButton(onPressed: onSkip, child: Text(l10n.onboardingSkip)),
              const Spacer(),
              ElevatedButton(
                onPressed: onContinue,
                child: Text(
                  isLast ? l10n.onboardingGetStarted : l10n.commonContinue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
