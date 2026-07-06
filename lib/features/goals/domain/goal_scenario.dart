import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_scenario.freezed.dart';

@freezed
abstract class GoalScenario with _$GoalScenario {
  const factory GoalScenario({
    required String id,
    required String goalId,
    required String name,
    required Map<String, dynamic> inputs,
    required bool isBaseline,
    required DateTime createdAt,
  }) = _GoalScenario;
}
