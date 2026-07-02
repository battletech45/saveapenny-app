import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/budgets/data/dto/budget_response.dart';
import 'package:saveapenny/features/budgets/data/dto/budget_status_response.dart';
import 'package:saveapenny/features/budgets/data/dto/create_budget_request.dart';
import 'package:saveapenny/features/budgets/data/dto/update_budget_request.dart';

part 'budgets_api.g.dart';

class BudgetsApi {
  BudgetsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedData<BudgetResponse>> list({
    String? period,
    int page = 0,
    int size = 20,
    String sort = 'startDate,desc',
  }) {
    return _apiClient.send<PaginatedData<BudgetResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/budgets',
        queryParameters: <String, Object?>{
          'period': period,
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) => PaginatedData<BudgetResponse>.fromJson(
        _readJsonMap(data),
        (item) => BudgetResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<BudgetStatusResponse> status(String budgetId) {
    return _apiClient.send<BudgetStatusResponse>(
      call: (dio) => dio.get<dynamic>('/budgets/$budgetId/status'),
      fromData: (data) => BudgetStatusResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<BudgetResponse> create(CreateBudgetRequest request) {
    return _apiClient.send<BudgetResponse>(
      call: (dio) => dio.post<dynamic>('/budgets', data: request.toJson()),
      fromData: (data) => BudgetResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<BudgetResponse> update({
    required String budgetId,
    required UpdateBudgetRequest request,
  }) {
    return _apiClient.send<BudgetResponse>(
      call: (dio) =>
          dio.put<dynamic>('/budgets/$budgetId', data: request.toJson()),
      fromData: (data) => BudgetResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> delete(String budgetId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>('/budgets/$budgetId'),
      fromData: (_) {},
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
BudgetsApi budgetsApi(Ref ref) {
  return BudgetsApi(ref.watch(apiClientProvider));
}
