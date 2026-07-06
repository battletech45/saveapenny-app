import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/goals/domain/goal_run.dart';

part 'goal_run_response.freezed.dart';
part 'goal_run_response.g.dart';

@freezed
abstract class GoalRunResponse with _$GoalRunResponse {
  const factory GoalRunResponse({
    required String id,
    required String goalId,
    String? scenarioId,
    required Map<String, dynamic> inputsSnapshot,
    Object? outputSummary,
    Object? outputSeries,
    required String feasibility,
    required String triggeredBy,
    required DateTime createdAt,
  }) = _GoalRunResponse;

  factory GoalRunResponse.fromJson(Map<String, dynamic> json) =>
      _$GoalRunResponseFromJson(json);
}

extension GoalRunResponseX on GoalRunResponse {
  GoalRun toDomain() {
    return GoalRun(
      id: id,
      goalId: goalId,
      scenarioId: scenarioId,
      inputsSnapshot: inputsSnapshot,
      outputSummary: outputSummary,
      outputSeries: outputSeries,
      feasibility: goalFeasibilityFromWire(feasibility),
      triggeredBy: goalRunTriggerFromWire(triggeredBy),
      createdAt: createdAt,
    );
  }
}

GoalFeasibility goalFeasibilityFromWire(String value) {
  return switch (value.toUpperCase()) {
    'ON_TRACK' => GoalFeasibility.onTrack,
    'TIGHT' => GoalFeasibility.tight,
    'AT_RISK' => GoalFeasibility.atRisk,
    'INFEASIBLE' => GoalFeasibility.infeasible,
    _ => throw FormatException('Unsupported goal feasibility: $value'),
  };
}

GoalRunTrigger goalRunTriggerFromWire(String value) {
  return switch (value.toUpperCase()) {
    'USER' => GoalRunTrigger.user,
    'AGENT' => GoalRunTrigger.agent,
    'PROGRESS_JOB' => GoalRunTrigger.progressJob,
    'WHAT_IF' => GoalRunTrigger.whatIf,
    _ => throw FormatException('Unsupported goal run trigger: $value'),
  };
}
