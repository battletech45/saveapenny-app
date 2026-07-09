import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_scenario_request.freezed.dart';
part 'create_scenario_request.g.dart';

@freezed
abstract class CreateScenarioRequest with _$CreateScenarioRequest {
  const factory CreateScenarioRequest({
    required String name,
    required Map<String, dynamic> inputs,
    bool? isBaseline,
  }) = _CreateScenarioRequest;

  factory CreateScenarioRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateScenarioRequestFromJson(json);
}
