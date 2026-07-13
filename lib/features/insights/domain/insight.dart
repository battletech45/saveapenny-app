import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight.freezed.dart';

enum InsightType { spendingPattern, anomaly, trend, recommendation, prediction }

enum InsightSeverity { info, warning, critical }

@freezed
abstract class Insight with _$Insight {
  const factory Insight({
    required String id,
    required InsightType type,
    required String title,
    required String summary,
    String? detail,
    String? categoryId,
    required InsightSeverity severity,
    String? metadata,
    required bool read,
    required bool dismissed,
    required DateTime generatedAt,
    required DateTime createdAt,
  }) = _Insight;
}
