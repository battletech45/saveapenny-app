import 'package:flutter/material.dart';

import 'package:saveapenny/l10n/generated/app_localizations.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.headline,
    required this.body,
  });

  final IconData icon;
  final String headline;
  final String body;
}

List<OnboardingPageData> onboardingPages(AppLocalizations l10n) {
  return <OnboardingPageData>[
    OnboardingPageData(
      icon: Icons.account_balance_wallet_outlined,
      headline: l10n.onboardingPage1Headline,
      body: l10n.onboardingPage1Body,
    ),
    OnboardingPageData(
      icon: Icons.flag_outlined,
      headline: l10n.onboardingPage2Headline,
      body: l10n.onboardingPage2Body,
    ),
    OnboardingPageData(
      icon: Icons.insights_outlined,
      headline: l10n.onboardingPage3Headline,
      body: l10n.onboardingPage3Body,
    ),
  ];
}
