import 'dart:io';

enum AppFlavor {
  dev,
  staging,
  prod;

  static AppFlavor fromWire(String value) {
    return switch (value.toLowerCase()) {
      'staging' => AppFlavor.staging,
      'prod' || 'production' => AppFlavor.prod,
      _ => AppFlavor.dev,
    };
  }
}

class AppEnvironment {
  AppEnvironment._({
    required this.flavor,
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.enableNetworkLogs,
    required this.revenueCatApiKey,
  });

  factory AppEnvironment.current() {
    final flavor = AppFlavor.fromWire(
      const String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev'),
    );
    final baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: Platform.isAndroid
          ? 'http://172.16.27.182:8080'
          : 'http://localhost:8080',
    );
    final revenueCatApiKey = Platform.isIOS
        ? const String.fromEnvironment('REVENUECAT_IOS_SDK_KEY')
        : const String.fromEnvironment('REVENUECAT_ANDROID_SDK_KEY');

    return AppEnvironment._(
      flavor: flavor,
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      enableNetworkLogs: flavor == AppFlavor.dev,
      revenueCatApiKey: revenueCatApiKey,
    );
  }

  final AppFlavor flavor;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableNetworkLogs;
  final String revenueCatApiKey;

  String get apiRoot => '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/api/v1';

  bool get isProduction => flavor == AppFlavor.prod;
}
