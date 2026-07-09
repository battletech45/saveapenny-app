import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/goals/domain/goal_scenario.dart';

part 'scenario_response.freezed.dart';
part 'scenario_response.g.dart';

@freezed
abstract class ScenarioResponse with _$ScenarioResponse {
  const factory ScenarioResponse({
    required String id,
    required String goalId,
    required String name,
    required Map<String, dynamic> inputs,
    required bool isBaseline,
    required DateTime createdAt,
  }) = _ScenarioResponse;

  factory ScenarioResponse.fromJson(Map<String, dynamic> json) =>
      _$ScenarioResponseFromJson(json);
}

extension ScenarioResponseX on ScenarioResponse {
  GoalScenario toDomain() {
    return GoalScenario(
      id: id,
      goalId: goalId,
      name: name,
      inputs: inputs,
      isBaseline: isBaseline,
      createdAt: createdAt,
    );
  }
}
