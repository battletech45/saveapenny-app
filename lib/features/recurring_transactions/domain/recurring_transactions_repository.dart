import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';

abstract interface class RecurringTransactionsRepository {
  Future<PaginatedData<RecurringTransaction>> list({
    int page = 0,
    int size = 20,
    String sort = 'nextRunDate,asc',
  });

  Future<RecurringTransaction> get(String recurringTransactionId);

  Future<RecurringTransaction> create({
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  });

  Future<RecurringTransaction> update({
    required String recurringTransactionId,
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    required RecurringStatus status,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  });

  Future<void> delete(String recurringTransactionId);

  Future<RecurringTransaction> pause(String recurringTransactionId);

  Future<RecurringTransaction> resume(String recurringTransactionId);

  Future<PaginatedData<RecurringTransactionHistoryEntry>> history(
    String recurringTransactionId, {
    int page = 0,
    int size = 20,
    String sort = 'scheduledDate,desc',
  });

  Future<List<UpcomingRecurringTransaction>> upcoming({int limit = 10});
}
