import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/router/app_router.dart';

part 'push_navigator.g.dart';

/// Seam over [GoRouter] navigation so [PushNotificationController] can be
/// unit-tested without constructing the full app router (which itself
/// depends on auth/onboarding state).
abstract interface class PushNavigator {
  void navigateTo(String route);
}

class GoRouterPushNavigator implements PushNavigator {
  const GoRouterPushNavigator(this._ref);

  final Ref _ref;

  @override
  void navigateTo(String route) {
    _ref.read(appRouterProvider).go(route);
  }
}

@Riverpod(keepAlive: true)
PushNavigator pushNavigator(Ref ref) {
  return GoRouterPushNavigator(ref);
}
