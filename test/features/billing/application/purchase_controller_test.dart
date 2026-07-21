import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:saveapenny/core/billing/revenuecat_client.dart';
import 'package:saveapenny/core/config/app_environment.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/application/purchase_controller.dart';
import 'package:saveapenny/features/billing/data/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/entitlement.dart';
import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';

class _FakeBillingRepository implements BillingRepository {
  _FakeBillingRepository({required this.entitlement});

  Entitlement entitlement;

  @override
  Future<Entitlement> getEntitlement() async => entitlement;

  @override
  Future<Entitlement> sync() async => entitlement;
}

class _FakeRevenueCatClient extends RevenueCatClient {
  _FakeRevenueCatClient({this.onPurchase, this.onRestore})
    : super(AppEnvironment.current());

  final Future<CustomerInfo> Function(Package package)? onPurchase;
  final Future<CustomerInfo> Function()? onRestore;

  @override
  Future<void> configure() async {}

  @override
  Future<CustomerInfo> purchasePackage(Package package) => onPurchase!(package);

  @override
  Future<CustomerInfo> restorePurchases() => onRestore!();
}

Package _package() {
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

void main() {
  test('purchase syncs entitlement and reports success', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(entitlement: _entitlement(Plan.plus)),
        ),
        revenueCatClientProvider.overrideWith(
          (ref) =>
              _FakeRevenueCatClient(onPurchase: (_) async => _customerInfo()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(purchaseControllerProvider.notifier)
        .purchase(_package());

    expect(succeeded, isTrue);
    final entitlement = container
        .read(entitlementControllerProvider)
        .requireValue;
    expect(entitlement.plan, Plan.plus);
    expect(entitlement.features.assistant, isTrue);
  });

  test('purchase treats user cancellation as a non-error no-op', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(entitlement: _entitlement(Plan.free)),
        ),
        revenueCatClientProvider.overrideWith(
          (ref) => _FakeRevenueCatClient(
            onPurchase: (_) => throw PlatformException(
              code: PurchasesErrorCode.purchaseCancelledError.index.toString(),
              message: 'cancelled',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(purchaseControllerProvider.notifier)
        .purchase(_package());

    expect(succeeded, isFalse);
    final state = container.read(purchaseControllerProvider);
    expect(state.hasError, isFalse);
  });

  test('purchase surfaces other platform errors as a Failure', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(entitlement: _entitlement(Plan.free)),
        ),
        revenueCatClientProvider.overrideWith(
          (ref) => _FakeRevenueCatClient(
            onPurchase: (_) => throw PlatformException(
              code: PurchasesErrorCode.storeProblemError.index.toString(),
              message: 'store unavailable',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(purchaseControllerProvider.notifier)
        .purchase(_package());

    expect(succeeded, isFalse);
    final state = container.read(purchaseControllerProvider);
    expect(state.hasError, isTrue);
  });

  test('restore succeeds and refreshes entitlement', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(entitlement: _entitlement(Plan.plus)),
        ),
        revenueCatClientProvider.overrideWith(
          (ref) =>
              _FakeRevenueCatClient(onRestore: () async => _customerInfo()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(purchaseControllerProvider.notifier)
        .restore();

    expect(succeeded, isTrue);
    final entitlement = container
        .read(entitlementControllerProvider)
        .requireValue;
    expect(entitlement.plan, Plan.plus);
  });
}
