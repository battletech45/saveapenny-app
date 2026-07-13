import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/insights/data/dto/insight_json.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';

part 'insight_response.freezed.dart';
part 'insight_response.g.dart';

@freezed
abstract class InsightResponse with _$InsightResponse {
  const factory InsightResponse({
    required String id,
    @JsonKey(fromJson: insightTypeFromJson, toJson: insightTypeToJson)
    required InsightType type,
    required String title,
    required String summary,
    String? detail,
    String? categoryId,
    @JsonKey(fromJson: insightSeverityFromJson, toJson: insightSeverityToJson)
    required InsightSeverity severity,
    String? metadata,
    required bool read,
    required bool dismissed,
    @JsonKey(fromJson: insightDateTime) required DateTime generatedAt,
    @JsonKey(fromJson: insightDateTime) required DateTime createdAt,
  }) = _InsightResponse;

  factory InsightResponse.fromJson(Map<String, dynamic> json) =>
      _$InsightResponseFromJson(json);
}

extension InsightResponseX on InsightResponse {
  Insight toDomain() {
    return Insight(
      id: id,
      type: type,
      title: title,
      summary: summary,
      detail: detail,
      categoryId: categoryId,
      severity: severity,
      metadata: metadata,
      read: read,
      dismissed: dismissed,
      generatedAt: generatedAt,
      createdAt: createdAt,
    );
  }
}
