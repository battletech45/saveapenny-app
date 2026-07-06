import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_run.freezed.dart';

enum GoalFeasibility { onTrack, tight, atRisk, infeasible }

enum GoalRunTrigger { user, agent, progressJob, whatIf }

@freezed
abstract class GoalRun with _$GoalRun {
  const factory GoalRun({
    required String id,
    required String goalId,
    String? scenarioId,
    required Map<String, dynamic> inputsSnapshot,
    Object? outputSummary,
    Object? outputSeries,
    required GoalFeasibility feasibility,
    required GoalRunTrigger triggeredBy,
    required DateTime createdAt,
  }) = _GoalRun;
}
