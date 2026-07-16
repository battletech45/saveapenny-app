import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/analytics/analytics_service.dart';

/// Attaches the cached Firebase Analytics client id (and platform) to
/// outgoing requests so the backend can correlate its own analytics events
/// with the same device/session the app already reports to Firebase.
class AnalyticsHeadersInterceptor extends Interceptor {
  AnalyticsHeadersInterceptor(this._ref);

  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final clientId = await _ref.read(analyticsClientIdProvider.future);
    if (clientId != null) {
      options.headers['X-Analytics-Client-Id'] = clientId;
    }
    options.headers['X-Client-Platform'] = Platform.isIOS ? 'ios' : 'android';
    handler.next(options);
  }
}
