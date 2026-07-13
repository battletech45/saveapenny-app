import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/insights/data/dto/insight_json.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';

part 'generate_insights_request.freezed.dart';
part 'generate_insights_request.g.dart';

@freezed
abstract class GenerateInsightsRequest with _$GenerateInsightsRequest {
  const factory GenerateInsightsRequest({
    @JsonKey(toJson: nullableInsightTypeToJson, includeIfNull: false)
    InsightType? type,
  }) = _GenerateInsightsRequest;

  factory GenerateInsightsRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateInsightsRequestFromJson(json);
}
