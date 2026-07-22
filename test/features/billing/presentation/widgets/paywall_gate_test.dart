import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/billing/data/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/entitlement.dart';
import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';
import 'package:saveapenny/features/billing/presentation/widgets/paywall_gate.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeBillingRepository implements BillingRepository {
  _FakeBillingRepository(this.entitlement);

  final Entitlement entitlement;

  @override
  Future<Entitlement> getEntitlement() async => entitlement;

  @override
  Future<Entitlement> sync() async => entitlement;
}

Entitlement _entitlement({required bool assistantUnlocked}) {
  return Entitlement(
    plan: assistantUnlocked ? Plan.plus : Plan.free,
    status: EntitlementStatus.active,
    isActive: assistantUnlocked,
    willRenew: assistantUnlocked,
    features: assistantUnlocked
        ? const FeatureAccess(
            assistant: true,
            insights: true,
            stocks: true,
            ocr: true,
            csvImport: true,
            reportExport: true,
            advancedRecurring: true,
            goalWhatIf: true,
          )
        : FeatureAccess.locked,
    limits: const PlanLimits(
      activeBudgets: 1,
      activeGoals: 1,
      reportHistoryMonths: 3,
    ),
  );
}

Future<void> _pumpGate(
  WidgetTester tester, {
  required Entitlement entitlement,
}) async {
  final container = ProviderContainer(
    overrides: [
      billingRepositoryProvider.overrideWith(
        (ref) => _FakeBillingRepository(entitlement),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PaywallGate(
          feature: 'assistant',
          isUnlocked: (features) => features.assistant,
          child: const Text('Assistant content'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the child when the feature is unlocked', (tester) async {
    await _pumpGate(tester, entitlement: _entitlement(assistantUnlocked: true));

    expect(find.text('Assistant content'), findsOneWidget);
  });

  testWidgets('renders the locked prompt when the feature is not unlocked', (
    tester,
  ) async {
    await _pumpGate(
      tester,
      entitlement: _entitlement(assistantUnlocked: false),
    );

    expect(find.text('Assistant content'), findsNothing);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.paywallLockedTitle), findsOneWidget);
    expect(find.text(l10n.paywallUpgradeCta), findsOneWidget);
  });
}
