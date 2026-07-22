import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:saveapenny/core/billing/revenuecat_client.dart';
import 'package:saveapenny/core/config/app_environment.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/billing/data/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/entitlement.dart';
import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';
import 'package:saveapenny/features/upgrade/presentation/upgrade_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeBillingRepository implements BillingRepository {
  _FakeBillingRepository(this.entitlement);

  Entitlement entitlement;

  @override
  Future<Entitlement> getEntitlement() async => entitlement;

  @override
  Future<Entitlement> sync() async => entitlement;
}

class _FakeRevenueCatClient extends RevenueCatClient {
  _FakeRevenueCatClient({this.onPurchase, this.onRestore, this.offerings})
    : super(AppEnvironment.current());

  final Future<CustomerInfo> Function(Package package)? onPurchase;
  final Future<CustomerInfo> Function()? onRestore;
  final Offerings? offerings;

  @override
  Future<void> configure() async {}

  @override
  Future<Offerings> getOfferings() async => offerings!;

  @override
  Future<CustomerInfo> purchasePackage(Package package) => onPurchase!(package);

  @override
  Future<CustomerInfo> restorePurchases() => onRestore!();
}

Package _monthlyPackage() {
  const context = PresentedOfferingContext('default', null, null);
  const product = StoreProduct(
    'plus_monthly',
    'SaveAPenny Plus monthly',
    'Plus Monthly',
    4.99,
    r'$4.99',
    'USD',
  );
  return const Package(r'$rc_monthly', PackageType.monthly, product, context);
}

Offerings _offerings({List<Package> packages = const <Package>[]}) {
  final offering = Offering(
    'default',
    'Default offering',
    const <String, Object>{},
    packages,
  );
  return Offerings(<String, Offering>{'default': offering}, current: offering);
}

CustomerInfo _customerInfo() {
  return const CustomerInfo(
    EntitlementInfos(<String, EntitlementInfo>{}, <String, EntitlementInfo>{}),
    <String, String?>{},
    <String>[],
    <String>[],
    <StoreTransaction>[],
    '2026-07-14T10:00:00Z',
    'user-1',
    <String, String?>{},
    '2026-07-14T10:00:00Z',
  );
}

Entitlement _entitlement(Plan plan) {
  return Entitlement(
    plan: plan,
    status: EntitlementStatus.active,
    isActive: plan == Plan.plus,
    willRenew: plan == Plan.plus,
    features: plan == Plan.plus
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

Future<ProviderContainer> _pumpUpgradeScreen(
  WidgetTester tester, {
  required _FakeRevenueCatClient client,
  required _FakeBillingRepository repository,
}) async {
  final container = ProviderContainer(
    overrides: [
      revenueCatClientProvider.overrideWith((ref) => client),
      billingRepositoryProvider.overrideWith((ref) => repository),
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
        home: const UpgradeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('renders offerings with store-provided pricing', (tester) async {
    await _pumpUpgradeScreen(
      tester,
      client: _FakeRevenueCatClient(
        offerings: _offerings(packages: <Package>[_monthlyPackage()]),
      ),
      repository: _FakeBillingRepository(_entitlement(Plan.free)),
    );

    expect(find.text('Plus Monthly'), findsOneWidget);
    expect(find.text(r'$4.99'), findsOneWidget);
  });

  testWidgets('shows the no-offerings message when none are configured', (
    tester,
  ) async {
    await _pumpUpgradeScreen(
      tester,
      client: _FakeRevenueCatClient(offerings: _offerings()),
      repository: _FakeBillingRepository(_entitlement(Plan.free)),
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.upgradeNoOfferingsMessage), findsOneWidget);
  });

  testWidgets('purchasing a package shows the success snackbar', (
    tester,
  ) async {
    await _pumpUpgradeScreen(
      tester,
      client: _FakeRevenueCatClient(
        offerings: _offerings(packages: <Package>[_monthlyPackage()]),
        onPurchase: (_) async => _customerInfo(),
      ),
      repository: _FakeBillingRepository(_entitlement(Plan.plus)),
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.paywallUpgradeCta));
    await tester.pumpAndSettle();

    expect(find.text(l10n.upgradeSuccessMessage), findsOneWidget);
  });

  testWidgets(
    'restore with no active entitlement shows the not-found message',
    (tester) async {
      await _pumpUpgradeScreen(
        tester,
        client: _FakeRevenueCatClient(
          offerings: _offerings(packages: <Package>[_monthlyPackage()]),
          onRestore: () async => _customerInfo(),
        ),
        repository: _FakeBillingRepository(_entitlement(Plan.free)),
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(l10n.upgradeRestoreCta));
      await tester.pumpAndSettle();

      expect(find.text(l10n.upgradeRestoreFailureMessage), findsOneWidget);
    },
  );

  testWidgets('restore SDK error shows the generic failure snackbar once', (
    tester,
  ) async {
    await _pumpUpgradeScreen(
      tester,
      client: _FakeRevenueCatClient(
        offerings: _offerings(packages: <Package>[_monthlyPackage()]),
        onRestore: () async => throw StateError('network down'),
      ),
      repository: _FakeBillingRepository(_entitlement(Plan.free)),
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.upgradeRestoreCta));
    await tester.pumpAndSettle();

    expect(find.text(l10n.upgradePurchaseFailedMessage), findsOneWidget);
    expect(find.text(l10n.upgradeRestoreFailureMessage), findsNothing);
  });
}
