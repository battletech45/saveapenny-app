import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/goals/data/dto/create_goal_request.dart';
import 'package:saveapenny/features/goals/data/dto/create_scenario_request.dart';
import 'package:saveapenny/features/goals/data/dto/goal_detail_response.dart';
import 'package:saveapenny/features/goals/data/dto/goal_response.dart';
import 'package:saveapenny/features/goals/data/dto/goal_run_response.dart';
import 'package:saveapenny/features/goals/data/dto/scenario_response.dart';
import 'package:saveapenny/features/goals/data/dto/update_goal_request.dart';
import 'package:saveapenny/features/goals/data/dto/update_goal_status_request.dart';
import 'package:saveapenny/features/goals/data/goals_api.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_detail.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';
import 'package:saveapenny/features/goals/domain/goal_scenario.dart';
import 'package:saveapenny/features/goals/domain/goals_repository.dart';

part 'goals_repository.g.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  const GoalsRepositoryImpl(this._goalsApi);

  final GoalsApi _goalsApi;

  @override
  Future<PaginatedData<Goal>> list({
    GoalStatus? status,
    GoalType? type,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _goalsApi.list(
      status: status == null ? null : goalStatusToWire(status),
      type: type == null ? null : goalTypeToWire(type),
      page: page,
      size: size,
    );

    return PaginatedData<Goal>(
      items: response.items
          .map((GoalResponse item) => item.toDomain())
          .toList(growable: false),
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  @override
  Future<Goal> create({
    required GoalType type,
    required String title,
    required num targetAmount,
    required String currency,
    required DateTime targetDate,
    String? linkedAccountId,
    required Map<String, dynamic> inputs,
  }) async {
    final response = await _goalsApi.create(
      CreateGoalRequest(
        type: goalTypeToWire(type),
        title: title,
        targetAmount: targetAmount,
        currency: currency,
        targetDate: targetDate.toIso8601String().split('T').first,
        linkedAccountId: linkedAccountId,
        inputs: inputs,
      ),
    );

    return response.toDomain();
  }

  @override
  Future<GoalDetail> getById(String goalId) async {
    final response = await _goalsApi.getById(goalId);
    return response.toDomain();
  }

  @override
  Future<Goal> update({
    required String goalId,
    String? title,
    num? targetAmount,
    String? currency,
    DateTime? targetDate,
    String? linkedAccountId,
    Map<String, dynamic>? inputs,
  }) async {
    final response = await _goalsApi.update(
      goalId: goalId,
      request: UpdateGoalRequest(
        title: title,
        targetAmount: targetAmount,
        currency: currency,
        targetDate: targetDate?.toIso8601String().split('T').first,
        linkedAccountId: linkedAccountId,
        inputs: inputs,
      ),
    );

    return response.toDomain();
  }

  @override
  Future<void> delete(String goalId) {
    return _goalsApi.delete(goalId);
  }

  @override
  Future<Goal> updateStatus({
    required String goalId,
    required GoalStatus status,
  }) async {
    final response = await _goalsApi.updateStatus(
      goalId: goalId,
      request: UpdateGoalStatusRequest(status: goalStatusToWire(status)),
    );
    return response.toDomain();
  }

  @override
  Future<GoalScenario> createScenario({
    required String goalId,
    required String name,
    required Map<String, dynamic> inputs,
    bool? isBaseline,
  }) async {
    final response = await _goalsApi.createScenario(
      goalId: goalId,
      request: CreateScenarioRequest(
        name: name,
        inputs: inputs,
        isBaseline: isBaseline,
      ),
    );

    return response.toDomain();
  }

  @override
  Future<List<GoalScenario>> listScenarios(String goalId) async {
    final response = await _goalsApi.listScenarios(goalId);
    return response
        .map((ScenarioResponse item) => item.toDomain())
        .toList(growable: false);
  }

  @override
  Future<PaginatedData<GoalRun>> listRuns(
    String goalId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _goalsApi.listRuns(goalId, page: page, size: size);

    return PaginatedData<GoalRun>(
      items: response.items
          .map((GoalRunResponse item) => item.toDomain())
          .toList(growable: false),
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }
}

@Riverpod(keepAlive: true)
GoalsRepository goalsRepository(Ref ref) {
  return GoalsRepositoryImpl(ref.watch(goalsApiProvider));
}
