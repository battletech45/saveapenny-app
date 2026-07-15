import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

class AnalyticsService {
  const AnalyticsService(this._analytics);

  final FirebaseAnalytics? _analytics;

  Future<void> logSignUp() => _tryLog(() => _analytics!.logSignUp(signUpMethod: 'email'));

  Future<void> logLogin() => _tryLog(() => _analytics!.logLogin(loginMethod: 'email'));

  Future<void> logAssistantMessageSent() => _tryLogEvent('assistant_message_sent');

  Future<void> logOcrScanStarted() => _tryLogEvent('ocr_scan_started');

  Future<void> logImportStarted() => _tryLogEvent('import_started');

  Future<void> logImportCompleted() => _tryLogEvent('import_completed');

  Future<void> logPaywallViewed({required String feature}) => _tryLogEvent(
    'paywall_viewed',
    parameters: <String, Object>{'feature': feature},
  );

  Future<void> logPurchaseCompleted({required String plan}) => _tryLogEvent(
    'purchase_completed',
    parameters: <String, Object>{'plan': plan},
  );

  Future<void> _tryLogEvent(String name, {Map<String, Object>? parameters}) {
    return _tryLog(
      () => _analytics!.logEvent(name: name, parameters: parameters),
    );
  }

  Future<void> _tryLog(Future<void> Function() call) async {
    if (_analytics == null) return;
    try {
      await call();
    } on Object {
      // Analytics should never crash the app.
    }
  }
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  FirebaseAnalytics? instance;
  try {
    instance = FirebaseAnalytics.instance;
  } on Object {
    // no-op: instance stays null when Firebase is unavailable (e.g. tests).
  }
  return AnalyticsService(instance);
}
