import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

enum GoalType { savings, debtPayoff, purchase, retirement, incomeTarget }

enum GoalStatus { draft, active, achieved, abandoned }

@freezed
abstract class Goal with _$Goal {
  const factory Goal({
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
  }) = _Goal;
}
