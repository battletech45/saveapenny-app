import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/budgets/data/budgets_api.dart';
import 'package:saveapenny/features/budgets/data/dto/budget_response.dart';
import 'package:saveapenny/features/budgets/data/dto/budget_status_response.dart';
import 'package:saveapenny/features/budgets/data/dto/create_budget_request.dart';
import 'package:saveapenny/features/budgets/data/dto/update_budget_request.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/budgets/domain/budgets_repository.dart';

part 'budgets_repository.g.dart';

class BudgetsRepositoryImpl implements BudgetsRepository {
  const BudgetsRepositoryImpl(this._budgetsApi);

  final BudgetsApi _budgetsApi;

  @override
  Future<PaginatedData<Budget>> list({
    BudgetPeriod? period,
    int page = 0,
    int size = 20,
    String sort = 'startDate,desc',
  }) async {
    final response = await _budgetsApi.list(
      period: period == null ? null : _budgetPeriodToWire(period),
      page: page,
      size: size,
      sort: sort,
    );

    return PaginatedData<Budget>(
      items: response.items
          .map((BudgetResponse item) => item.toDomain())
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
  Future<BudgetStatus> status(String budgetId) async {
    final response = await _budgetsApi.status(budgetId);
    return response.toDomain();
  }

  @override
  Future<Budget> create({
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _budgetsApi.create(
      CreateBudgetRequest(
        categoryId: categoryId,
        amount: amount,
        period: _budgetPeriodToWire(period),
        startDate: _toWireDate(startDate),
        endDate: _toWireDate(endDate),
      ),
    );

    return response.toDomain();
  }

  @override
  Future<Budget> update({
    required String budgetId,
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _budgetsApi.update(
      budgetId: budgetId,
      request: UpdateBudgetRequest(
        categoryId: categoryId,
        amount: amount,
        period: _budgetPeriodToWire(period),
        startDate: _toWireDate(startDate),
        endDate: _toWireDate(endDate),
      ),
    );

    return response.toDomain();
  }

  @override
  Future<void> delete(String budgetId) {
    return _budgetsApi.delete(budgetId);
  }
}

String _budgetPeriodToWire(BudgetPeriod period) {
  return switch (period) {
    BudgetPeriod.monthly => 'MONTHLY',
    BudgetPeriod.yearly => 'YEARLY',
  };
}

String _toWireDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

@Riverpod(keepAlive: true)
BudgetsRepository budgetsRepository(Ref ref) {
  return BudgetsRepositoryImpl(ref.watch(budgetsApiProvider));
}
