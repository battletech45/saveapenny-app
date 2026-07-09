import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/goals/data/dto/create_goal_request.dart';
import 'package:saveapenny/features/goals/data/dto/create_scenario_request.dart';
import 'package:saveapenny/features/goals/data/dto/goal_detail_response.dart';
import 'package:saveapenny/features/goals/data/dto/goal_response.dart';
import 'package:saveapenny/features/goals/data/dto/goal_run_response.dart';
import 'package:saveapenny/features/goals/data/dto/scenario_response.dart';
import 'package:saveapenny/features/goals/data/dto/update_goal_request.dart';
import 'package:saveapenny/features/goals/data/dto/update_goal_status_request.dart';

part 'goals_api.g.dart';

class GoalsApi {
  const GoalsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedData<GoalResponse>> list({
    String? status,
    String? type,
    int page = 0,
    int size = 20,
    String sort = 'targetDate,asc',
  }) {
    return _apiClient.send<PaginatedData<GoalResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/goals',
        queryParameters: <String, Object?>{
          'status': status,
          'type': type,
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) => PaginatedData<GoalResponse>.fromJson(
        _readJsonMap(data),
        (item) => GoalResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<GoalResponse> create(CreateGoalRequest request) {
    return _apiClient.send<GoalResponse>(
      call: (dio) => dio.post<dynamic>('/goals', data: request.toJson()),
      fromData: (data) => GoalResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<GoalDetailResponse> getById(String goalId) {
    return _apiClient.send<GoalDetailResponse>(
      call: (dio) => dio.get<dynamic>('/goals/$goalId'),
      fromData: (data) => GoalDetailResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<GoalResponse> update({
    required String goalId,
    required UpdateGoalRequest request,
  }) {
    return _apiClient.send<GoalResponse>(
      call: (dio) =>
          dio.patch<dynamic>('/goals/$goalId', data: request.toJson()),
      fromData: (data) => GoalResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> delete(String goalId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>('/goals/$goalId'),
      fromData: (_) {},
    );
  }

  Future<GoalResponse> updateStatus({
    required String goalId,
    required UpdateGoalStatusRequest request,
  }) {
    return _apiClient.send<GoalResponse>(
      call: (dio) =>
          dio.patch<dynamic>('/goals/$goalId/status', data: request.toJson()),
      fromData: (data) => GoalResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<ScenarioResponse> createScenario({
    required String goalId,
    required CreateScenarioRequest request,
  }) {
    return _apiClient.send<ScenarioResponse>(
      call: (dio) =>
          dio.post<dynamic>('/goals/$goalId/scenarios', data: request.toJson()),
      fromData: (data) => ScenarioResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<List<ScenarioResponse>> listScenarios(String goalId) {
    return _apiClient.send<List<ScenarioResponse>>(
      call: (dio) => dio.get<dynamic>('/goals/$goalId/scenarios'),
      fromData: (data) {
        if (data is! List<Object?>) {
          throw const FormatException('Expected a JSON array.');
        }

        return data
            .map((item) => ScenarioResponse.fromJson(_readJsonMap(item)))
            .toList(growable: false);
      },
    );
  }

  Future<PaginatedData<GoalRunResponse>> listRuns(
    String goalId, {
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) {
    return _apiClient.send<PaginatedData<GoalRunResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/goals/$goalId/runs',
        queryParameters: <String, Object?>{
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) => PaginatedData<GoalRunResponse>.fromJson(
        _readJsonMap(data),
        (item) => GoalRunResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
GoalsApi goalsApi(Ref ref) {
  return GoalsApi(ref.watch(apiClientProvider));
}
