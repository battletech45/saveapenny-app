import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/analytics/analytics_service.dart';
import 'package:saveapenny/core/billing/revenuecat_client.dart';
import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';

part 'purchase_controller.g.dart';

@riverpod
Future<Offerings> billingOfferings(Ref ref) {
  return ref.read(revenueCatClientProvider).getOfferings();
}

@riverpod
class PurchaseController extends _$PurchaseController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  void clearFeedback() {
    state = const AsyncData(null);
  }

  /// Returns true when the purchase succeeded and entitlement was refreshed.
  Future<bool> purchase(Package package) async {
    state = const AsyncLoading();

    try {
      await ref.read(revenueCatClientProvider).purchasePackage(package);
      await ref
          .read(entitlementControllerProvider.notifier)
          .syncAfterPurchase();
      final entitlement = ref.read(entitlementControllerProvider).value;
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logPurchaseCompleted(plan: entitlement?.plan.wireValue ?? 'plus'),
      );
      state = const AsyncData(null);
      return true;
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError) {
        state = const AsyncData(null);
        return false;
      }
      state = AsyncError(
        Failure.unknown(message: error.message),
        StackTrace.current,
      );
      return false;
    } on Object catch (error, stackTrace) {
      state = AsyncError(
        Failure.unknown(message: error.toString()),
        stackTrace,
      );
      return false;
    }
  }

  /// Returns true only when the restore actually reinstated an active
  /// entitlement — a clean restore call with nothing to restore is not an
  /// error, so it must not also trigger the generic error snackbar.
  Future<bool> restore() async {
    state = const AsyncLoading();

    try {
      await ref.read(revenueCatClientProvider).restorePurchases();
      await ref
          .read(entitlementControllerProvider.notifier)
          .syncAfterPurchase();
      final restored =
          ref.read(entitlementControllerProvider).value?.isActive ?? false;
      if (restored) {
        unawaited(ref.read(analyticsServiceProvider).logRestoreCompleted());
      }
      state = const AsyncData(null);
      return restored;
    } on Object catch (error, stackTrace) {
      state = AsyncError(
        Failure.unknown(message: error.toString()),
        stackTrace,
      );
      return false;
    }
  }
}
