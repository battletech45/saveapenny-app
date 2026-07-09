import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/goals/domain/goal.dart';

part 'goal_response.freezed.dart';
part 'goal_response.g.dart';

@freezed
abstract class GoalResponse with _$GoalResponse {
  const factory GoalResponse({
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
  }) = _GoalResponse;

  factory GoalResponse.fromJson(Map<String, dynamic> json) =>
      _$GoalResponseFromJson(json);
}

extension GoalResponseX on GoalResponse {
  Goal toDomain() {
    return Goal(
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
    );
  }
}

GoalType goalTypeFromWire(String value) {
  return switch (value.toUpperCase()) {
    'SAVINGS' => GoalType.savings,
    'DEBT_PAYOFF' => GoalType.debtPayoff,
    'PURCHASE' => GoalType.purchase,
    'RETIREMENT' => GoalType.retirement,
    'INCOME_TARGET' => GoalType.incomeTarget,
    _ => throw FormatException('Unsupported goal type: $value'),
  };
}

String goalTypeToWire(GoalType value) {
  return switch (value) {
    GoalType.savings => 'SAVINGS',
    GoalType.debtPayoff => 'DEBT_PAYOFF',
    GoalType.purchase => 'PURCHASE',
    GoalType.retirement => 'RETIREMENT',
    GoalType.incomeTarget => 'INCOME_TARGET',
  };
}

GoalStatus goalStatusFromWire(String value) {
  return switch (value.toUpperCase()) {
    'DRAFT' => GoalStatus.draft,
    'ACTIVE' => GoalStatus.active,
    'ACHIEVED' => GoalStatus.achieved,
    'ABANDONED' => GoalStatus.abandoned,
    _ => throw FormatException('Unsupported goal status: $value'),
  };
}

String goalStatusToWire(GoalStatus value) {
  return switch (value) {
    GoalStatus.draft => 'DRAFT',
    GoalStatus.active => 'ACTIVE',
    GoalStatus.achieved => 'ACHIEVED',
    GoalStatus.abandoned => 'ABANDONED',
  };
}
