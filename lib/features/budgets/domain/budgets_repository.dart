import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';

abstract interface class BudgetsRepository {
  Future<PaginatedData<Budget>> list({
    BudgetPeriod? period,
    int page = 0,
    int size = 20,
    String sort = 'startDate,desc',
  });

  Future<BudgetStatus> status(String budgetId);

  Future<Budget> create({
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Budget> update({
    required String budgetId,
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<void> delete(String budgetId);
}
