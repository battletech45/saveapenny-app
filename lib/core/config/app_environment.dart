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
  });

  factory AppEnvironment.current() {
    final flavor = AppFlavor.fromWire(
      const String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev'),
    );
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    );

    return AppEnvironment._(
      flavor: flavor,
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      enableNetworkLogs: flavor == AppFlavor.dev,
    );
  }

  final AppFlavor flavor;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableNetworkLogs;

  String get apiRoot => '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/api/v1';

  bool get isProduction => flavor == AppFlavor.prod;
}
