import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/data/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/entitlement.dart';
import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';

class _FakeBillingRepository implements BillingRepository {
  _FakeBillingRepository({this.onGetEntitlement, this.onSync});

  final Future<Entitlement> Function()? onGetEntitlement;
  final Future<Entitlement> Function()? onSync;

  @override
  Future<Entitlement> getEntitlement() => onGetEntitlement!();

  @override
  Future<Entitlement> sync() => onSync!();
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
  test('build loads the entitlement from the repository', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(
            onGetEntitlement: () async => _entitlement(Plan.free),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final entitlement = await container.read(
      entitlementControllerProvider.future,
    );

    expect(entitlement.plan, Plan.free);
    expect(entitlement.features.assistant, isFalse);
  });

  test('build surfaces a mapped Failure when the fetch fails', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(
            onGetEntitlement: () async => throw const Failure.unauthenticated(
              code: ApiErrorCode.unauthorized,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(entitlementControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(entitlementControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<UnauthenticatedFailure>());
  });

  test('syncAfterPurchase refreshes state from the sync endpoint', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(
            onGetEntitlement: () async => _entitlement(Plan.free),
            onSync: () async => _entitlement(Plan.plus),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(entitlementControllerProvider.future);
    await container
        .read(entitlementControllerProvider.notifier)
        .syncAfterPurchase();

    final state = container.read(entitlementControllerProvider).requireValue;
    expect(state.plan, Plan.plus);
    expect(state.features.assistant, isTrue);
  });

  test('refreshQuietly updates state without an interim loading state', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(
            onGetEntitlement: () async => _entitlement(Plan.free),
            onSync: () async => _entitlement(Plan.plus),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(entitlementControllerProvider.future);

    final states = <AsyncValue<Entitlement>>[];
    container.listen(
      entitlementControllerProvider,
      (previous, next) => states.add(next),
      fireImmediately: false,
    );

    await container
        .read(entitlementControllerProvider.notifier)
        .refreshQuietly();

    expect(states, hasLength(1));
    expect(states.single.hasValue, isTrue);
    expect(states.single.requireValue.plan, Plan.plus);

    final state = container.read(entitlementControllerProvider).requireValue;
    expect(state.plan, Plan.plus);
  });

  test('refreshQuietly surfaces a mapped Failure without clearing prior data first', () async {
    final container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWith(
          (ref) => _FakeBillingRepository(
            onGetEntitlement: () async => _entitlement(Plan.plus),
            onSync: () async => throw const Failure.unauthenticated(
              code: ApiErrorCode.unauthorized,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(entitlementControllerProvider.future);
    await container
        .read(entitlementControllerProvider.notifier)
        .refreshQuietly();

    final state = container.read(entitlementControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<UnauthenticatedFailure>());
  });
}
