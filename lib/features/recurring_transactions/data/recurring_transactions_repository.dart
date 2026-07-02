import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/create_recurring_transaction_request.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/recurring_transaction_history_entry_response.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/recurring_transaction_response.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/upcoming_recurring_transaction_response.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/update_recurring_transaction_request.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_api.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';

part 'recurring_transactions_repository.g.dart';

class RecurringTransactionsRepositoryImpl
    implements RecurringTransactionsRepository {
  const RecurringTransactionsRepositoryImpl(this._api);

  final RecurringTransactionsApi _api;

  @override
  Future<PaginatedData<RecurringTransaction>> list({
    int page = 0,
    int size = 20,
    String sort = 'nextRunDate,asc',
  }) async {
    final response = await _api.list(page: page, size: size, sort: sort);

    return PaginatedData<RecurringTransaction>(
      items: response.items
          .map((RecurringTransactionResponse item) => item.toDomain())
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
  Future<RecurringTransaction> get(String recurringTransactionId) async {
    final response = await _api.get(recurringTransactionId);
    return response.toDomain();
  }

  @override
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
  }) async {
    final response = await _api.create(
      CreateRecurringTransactionRequest(
        accountId: accountId,
        categoryId: categoryId,
        type: _typeToWire(type),
        amount: amount,
        frequency: _frequencyToWire(frequency),
        nextRunDate: _toWireDate(nextRunDate),
        name: _normalizeText(name),
        description: _normalizeText(description),
        startDate: startDate == null ? null : _toWireDate(startDate),
        endDate: endDate == null ? null : _toWireDate(endDate),
        classification: classification == null
            ? null
            : _classificationToWire(classification),
      ),
    );

    return response.toDomain();
  }

  @override
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
  }) async {
    final response = await _api.update(
      recurringTransactionId: recurringTransactionId,
      request: UpdateRecurringTransactionRequest(
        accountId: accountId,
        categoryId: categoryId,
        type: _typeToWire(type),
        amount: amount,
        frequency: _frequencyToWire(frequency),
        nextRunDate: _toWireDate(nextRunDate),
        status: _statusToWire(status),
        name: _normalizeText(name),
        description: _normalizeText(description),
        startDate: startDate == null ? null : _toWireDate(startDate),
        endDate: endDate == null ? null : _toWireDate(endDate),
        classification: classification == null
            ? null
            : _classificationToWire(classification),
      ),
    );

    return response.toDomain();
  }

  @override
  Future<void> delete(String recurringTransactionId) {
    return _api.delete(recurringTransactionId);
  }

  @override
  Future<RecurringTransaction> pause(String recurringTransactionId) async {
    final response = await _api.pause(recurringTransactionId);
    return response.toDomain();
  }

  @override
  Future<RecurringTransaction> resume(String recurringTransactionId) async {
    final response = await _api.resume(recurringTransactionId);
    return response.toDomain();
  }

  @override
  Future<PaginatedData<RecurringTransactionHistoryEntry>> history(
    String recurringTransactionId, {
    int page = 0,
    int size = 20,
    String sort = 'scheduledDate,desc',
  }) async {
    final response = await _api.history(
      recurringTransactionId,
      page: page,
      size: size,
      sort: sort,
    );

    return PaginatedData<RecurringTransactionHistoryEntry>(
      items: response.items
          .map(
            (RecurringTransactionHistoryEntryResponse item) => item.toDomain(),
          )
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
  Future<List<UpcomingRecurringTransaction>> upcoming({int limit = 10}) async {
    final response = await _api.upcoming(limit: limit);
    return response
        .map((UpcomingRecurringTransactionResponse item) => item.toDomain())
        .toList(growable: false);
  }
}

String _typeToWire(RecurringTransactionType value) {
  return switch (value) {
    RecurringTransactionType.income => 'INCOME',
    RecurringTransactionType.expense => 'EXPENSE',
  };
}

String _frequencyToWire(RecurringFrequency value) {
  return switch (value) {
    RecurringFrequency.daily => 'DAILY',
    RecurringFrequency.weekly => 'WEEKLY',
    RecurringFrequency.monthly => 'MONTHLY',
    RecurringFrequency.yearly => 'YEARLY',
  };
}

String _statusToWire(RecurringStatus value) {
  return switch (value) {
    RecurringStatus.active => 'ACTIVE',
    RecurringStatus.paused => 'PAUSED',
    RecurringStatus.expired => 'EXPIRED',
    RecurringStatus.failed => 'FAILED',
  };
}

String _classificationToWire(RecurringClassification value) {
  return switch (value) {
    RecurringClassification.paycheck => 'PAYCHECK',
    RecurringClassification.subscription => 'SUBSCRIPTION',
    RecurringClassification.rent => 'RENT',
    RecurringClassification.utility => 'UTILITY',
    RecurringClassification.loanPayment => 'LOAN_PAYMENT',
    RecurringClassification.savingsContribution => 'SAVINGS_CONTRIBUTION',
    RecurringClassification.other => 'OTHER',
  };
}

String _toWireDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _normalizeText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

@Riverpod(keepAlive: true)
RecurringTransactionsRepository recurringTransactionsRepository(Ref ref) {
  return RecurringTransactionsRepositoryImpl(
    ref.watch(recurringTransactionsApiProvider),
  );
}
