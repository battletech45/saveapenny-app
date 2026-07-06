import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/goals/data/dto/goal_response.dart';
import 'package:saveapenny/features/goals/data/dto/goal_run_response.dart';
import 'package:saveapenny/features/goals/data/dto/scenario_response.dart';
import 'package:saveapenny/features/goals/domain/goal_detail.dart';

part 'goal_detail_response.freezed.dart';
part 'goal_detail_response.g.dart';

@freezed
abstract class GoalDetailResponse with _$GoalDetailResponse {
  const factory GoalDetailResponse({
    required String id,
    required String type,
    required String title,
    required num targetAmount,
    required String currency,
    required DateTime targetDate,
    String? linkedAccountId,
    required String status,
    required Map<String, dynamic> inputs,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(<ScenarioResponse>[]) List<ScenarioResponse> scenarios,
    GoalRunResponse? latestRun,
  }) = _GoalDetailResponse;

  factory GoalDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$GoalDetailResponseFromJson(json);
}

extension GoalDetailResponseX on GoalDetailResponse {
  GoalDetail toDomain() {
    return GoalDetail(
      id: id,
      type: goalTypeFromWire(type),
      title: title,
      targetAmount: targetAmount,
      currency: currency,
      targetDate: targetDate,
      linkedAccountId: linkedAccountId,
      status: goalStatusFromWire(status),
      inputs: inputs,
      createdAt: createdAt,
      updatedAt: updatedAt,
      scenarios: scenarios
          .map((item) => item.toDomain())
          .toList(growable: false),
      latestRun: latestRun?.toDomain(),
    );
  }
}
