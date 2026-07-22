import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/config/app_environment.dart';
import 'package:saveapenny/core/network/dio_client.dart';

part 'revenuecat_client.g.dart';

/// Thin wrapper around the `purchases_flutter` SDK. Holds no business logic —
/// entitlement truth lives on the backend (see `features/billing`).
class RevenueCatClient {
  RevenueCatClient(this._environment);

  final AppEnvironment _environment;
  bool _configured = false;
  Future<void>? _configuring;
  final StreamController<CustomerInfo> _customerInfoUpdates =
      StreamController<CustomerInfo>.broadcast();

  /// Fires whenever the SDK observes a subscriber state change (renewal,
  /// cancellation, billing issue, cross-device restore) — not just in
  /// response to a purchase/restore call made from this app session.
  Stream<CustomerInfo> get customerInfoUpdates => _customerInfoUpdates.stream;

  /// Idempotent and safe to call concurrently — every SDK entry point below
  /// awaits this first so the app can never reach `Purchases.*` before
  /// `Purchases.configure` has actually completed (that ordering bug is what
  /// causes the native "Purchases has not been configured" fatal error).
  Future<void> configure() {
    if (_configured) {
      return Future<void>.value();
    }
    return _configuring ??= _doConfigure();
  }

  Future<void> _doConfigure() async {
    if (_environment.revenueCatApiKey.isEmpty) {
      return;
    }
    await Purchases.setLogLevel(
      _environment.enableNetworkLogs ? LogLevel.debug : LogLevel.warn,
    );
    await Purchases.configure(
      PurchasesConfiguration(_environment.revenueCatApiKey),
    );
    Purchases.addCustomerInfoUpdateListener(_customerInfoUpdates.add);
    _configured = true;
  }

  Future<void> logIn(String appUserId) async {
    await configure();
    if (!_configured) {
      return;
    }
    await Purchases.logIn(appUserId);
  }

  Future<void> logOut() async {
    await configure();
    if (!_configured) {
      return;
    }
    await Purchases.logOut();
  }

  Future<Offerings> getOfferings() async {
    await configure();
    if (!_configured) {
      throw StateError('RevenueCat is not configured: missing SDK key.');
    }
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    await configure();
    if (!_configured) {
      throw StateError('RevenueCat is not configured: missing SDK key.');
    }
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    await configure();
    if (!_configured) {
      throw StateError('RevenueCat is not configured: missing SDK key.');
    }
    return Purchases.restorePurchases();
  }

  Future<void> dispose() => _customerInfoUpdates.close();
}

@Riverpod(keepAlive: true)
RevenueCatClient revenueCatClient(Ref ref) {
  final client = RevenueCatClient(ref.watch(appEnvironmentProvider));
  ref.onDispose(() => unawaited(client.dispose()));
  return client;
}
