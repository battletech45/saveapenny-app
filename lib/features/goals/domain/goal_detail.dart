import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';
import 'package:saveapenny/features/goals/domain/goal_scenario.dart';

part 'goal_detail.freezed.dart';

@freezed
abstract class GoalDetail with _$GoalDetail {
  const factory GoalDetail({
    required String id,
    required GoalType type,
    required String title,
    required num targetAmount,
    required String currency,
    required DateTime targetDate,
    String? linkedAccountId,
    required GoalStatus status,
    required Map<String, dynamic> inputs,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<GoalScenario> scenarios,
    GoalRun? latestRun,
  }) = _GoalDetail;
}
