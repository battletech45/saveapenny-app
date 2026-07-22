import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/billing/data/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/entitlement.dart';

part 'entitlement_controller.g.dart';

@Riverpod(keepAlive: true)
class EntitlementController extends _$EntitlementController {
  @override
  Future<Entitlement> build() {
    return ref.read(billingRepositoryProvider).getEntitlement();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(billingRepositoryProvider).getEntitlement(),
    );
  }

  Future<void> syncAfterPurchase() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(billingRepositoryProvider).sync(),
    );
  }

  /// Same backend sync as [syncAfterPurchase], but without the interim
  /// `AsyncLoading` state — used for background reconciliation (e.g. a
  /// RevenueCat `CustomerInfo` update while the app is foregrounded) where
  /// flashing every `PaywallGate`/entitlement watcher to a loading state
  /// would be a visible regression, not just a refresh.
  Future<void> refreshQuietly() async {
    final result = await AsyncValue.guard(
      () => ref.read(billingRepositoryProvider).sync(),
    );
    state = result;
  }
}
