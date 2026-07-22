import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/billing/presentation/widgets/plan_limit_banner.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('PlanLimitBanner', () {
    testWidgets('renders nothing when the plan has no cap', (tester) async {
      await _pump(
        tester,
        const PlanLimitBanner(used: 5, max: null, message: 'unused'),
      );

      expect(find.byType(PlanLimitBanner), findsOneWidget);
      expect(find.text('unused'), findsNothing);
    });

    testWidgets('renders nothing when under the cap', (tester) async {
      await _pump(
        tester,
        const PlanLimitBanner(used: 1, max: 3, message: 'unused'),
      );

      expect(find.text('unused'), findsNothing);
    });

    testWidgets('renders the usage label and message when at the cap', (
      tester,
    ) async {
      await _pump(
        tester,
        const PlanLimitBanner(used: 3, max: 3, message: 'Limit reached'),
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.planLimitUsageLabel(3, 3)), findsOneWidget);
      expect(find.text('Limit reached'), findsOneWidget);
      expect(find.text(l10n.planLimitReachedCta), findsOneWidget);
    });
  });

  group('PlanLockedFeatureBanner', () {
    testWidgets('renders nothing when unlocked', (tester) async {
      await _pump(
        tester,
        const PlanLockedFeatureBanner(isUnlocked: true, message: 'unused'),
      );

      expect(find.text('unused'), findsNothing);
    });

    testWidgets('renders the message and CTA when locked', (tester) async {
      await _pump(
        tester,
        const PlanLockedFeatureBanner(
          isUnlocked: false,
          message: 'Requires Plus',
        ),
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text('Requires Plus'), findsOneWidget);
      expect(find.text(l10n.planLimitReachedCta), findsOneWidget);
    });
  });
}
