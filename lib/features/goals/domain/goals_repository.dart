import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_detail.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';
import 'package:saveapenny/features/goals/domain/goal_scenario.dart';

abstract interface class GoalsRepository {
  Future<PaginatedData<Goal>> list({
    GoalStatus? status,
    GoalType? type,
    int page = 0,
    int size = 20,
  });

  Future<Goal> create({
    required GoalType type,
    required String title,
    required num targetAmount,
    required String currency,
    required DateTime targetDate,
    String? linkedAccountId,
    required Map<String, dynamic> inputs,
  });

  Future<GoalDetail> getById(String goalId);

  Future<Goal> update({
    required String goalId,
    String? title,
    num? targetAmount,
    String? currency,
    DateTime? targetDate,
    String? linkedAccountId,
    Map<String, dynamic>? inputs,
  });

  Future<void> delete(String goalId);

  Future<Goal> updateStatus({
    required String goalId,
    required GoalStatus status,
  });

  Future<GoalScenario> createScenario({
    required String goalId,
    required String name,
    required Map<String, dynamic> inputs,
    bool? isBaseline,
  });

  Future<List<GoalScenario>> listScenarios(String goalId);

  Future<PaginatedData<GoalRun>> listRuns(
    String goalId, {
    int page = 0,
    int size = 20,
  });
}
