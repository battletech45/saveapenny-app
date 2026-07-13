import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_insights_response.freezed.dart';
part 'generate_insights_response.g.dart';

@freezed
abstract class GenerateInsightsResponse with _$GenerateInsightsResponse {
  const factory GenerateInsightsResponse({required int generatedCount}) =
      _GenerateInsightsResponse;

  factory GenerateInsightsResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateInsightsResponseFromJson(json);
}
