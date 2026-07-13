import 'package:saveapenny/features/insights/domain/insight.dart';

InsightType insightTypeFromJson(String raw) {
  return switch (raw) {
    'SPENDING_PATTERN' => InsightType.spendingPattern,
    'ANOMALY' => InsightType.anomaly,
    'TREND' => InsightType.trend,
    'RECOMMENDATION' => InsightType.recommendation,
    'PREDICTION' => InsightType.prediction,
    _ => throw FormatException('Unsupported insight type: $raw'),
  };
}

String insightTypeToJson(InsightType type) {
  return switch (type) {
    InsightType.spendingPattern => 'SPENDING_PATTERN',
    InsightType.anomaly => 'ANOMALY',
    InsightType.trend => 'TREND',
    InsightType.recommendation => 'RECOMMENDATION',
    InsightType.prediction => 'PREDICTION',
  };
}

String? nullableInsightTypeToJson(InsightType? type) {
  return type == null ? null : insightTypeToJson(type);
}

InsightSeverity insightSeverityFromJson(String raw) {
  return switch (raw) {
    'INFO' => InsightSeverity.info,
    'WARNING' => InsightSeverity.warning,
    'CRITICAL' => InsightSeverity.critical,
    _ => throw FormatException('Unsupported insight severity: $raw'),
  };
}

String insightSeverityToJson(InsightSeverity severity) {
  return switch (severity) {
    InsightSeverity.info => 'INFO',
    InsightSeverity.warning => 'WARNING',
    InsightSeverity.critical => 'CRITICAL',
  };
}

DateTime insightDateTime(Object? raw) {
  if (raw is String) {
    return DateTime.parse(raw);
  }

  throw FormatException('Unsupported date-time value: $raw');
}
