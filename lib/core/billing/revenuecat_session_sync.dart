import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/billing/revenuecat_client.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/users/data/users_repository.dart';

part 'revenuecat_session_sync.g.dart';

/// Keeps the RevenueCat `appUserID` aligned with the backend user UUID.
/// Never uses email as identity (see monetization plan). Failures here must
/// never block auth — billing identity sync is best-effort.
@Riverpod(keepAlive: true)
class RevenueCatSessionSync extends _$RevenueCatSessionSync {
  StreamSubscription<CustomerInfo>? _customerInfoSubscription;
  bool _skippedInitialCustomerInfo = false;

  @override
  void build() {
    ref.onDispose(() {
      unawaited(_customerInfoSubscription?.cancel());
    });
  }

  Future<void> onSessionRestored() async {
    try {
      final profile = await ref.read(usersRepositoryProvider).getCurrentUser();
      final client = ref.read(revenueCatClientProvider);
      await client.configure();
      await client.logIn(profile.id);
      // Reconcile with RevenueCat on every launch — entitlement state must
      // never depend on the user visiting the profile/paywall screen first.
      await ref
          .read(entitlementControllerProvider.notifier)
          .syncAfterPurchase();
      _listenForCustomerInfoUpdates(client);
    } on Object {
      // best-effort: entitlement sync will still work once retried.
    }
  }

  /// Renewals, cancellations, and billing-issue transitions can happen while
  /// the app is foregrounded, not only right after a purchase/restore call —
  /// this keeps the backend entitlement snapshot from going stale until the
  /// next app launch.
  void _listenForCustomerInfoUpdates(RevenueCatClient client) {
    if (_customerInfoSubscription != null) {
      return;
    }
    _skippedInitialCustomerInfo = false;
    _customerInfoSubscription = client.customerInfoUpdates.listen((_) {
      // The SDK replays the current CustomerInfo immediately on listener
      // registration; skip that one since syncAfterPurchase() above already
      // covered it — otherwise every login does a redundant backend sync.
      if (!_skippedInitialCustomerInfo) {
        _skippedInitialCustomerInfo = true;
        return;
      }
      unawaited(
        ref.read(entitlementControllerProvider.notifier).refreshQuietly(),
      );
    });
  }

  Future<void> onLogout() async {
    try {
      await _customerInfoSubscription?.cancel();
      _customerInfoSubscription = null;
      await ref.read(revenueCatClientProvider).logOut();
    } on Object {
      // best-effort.
    }
  }
}
