import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/transactions/data/dto/create_transaction_request.dart';
import 'package:saveapenny/features/transactions/data/dto/create_transfer_request.dart';
import 'package:saveapenny/features/transactions/data/dto/transaction_response.dart';
import 'package:saveapenny/features/transactions/data/dto/update_transaction_request.dart';
import 'package:saveapenny/features/transactions/data/transactions_api.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/features/transactions/domain/transactions_repository.dart';

part 'transactions_repository.g.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  const TransactionsRepositoryImpl(this._transactionsApi);

  final TransactionsApi _transactionsApi;

  @override
  Future<PaginatedData<Transaction>> list({
    DateTime? from,
    DateTime? to,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    num? minAmount,
    num? maxAmount,
    String? keyword,
    int page = 0,
    int size = 20,
    String sort = 'transactionDate,desc',
  }) async {
    final response = await _transactionsApi.list(
      from: from,
      to: to,
      type: type == null ? null : _transactionTypeToWire(type),
      accountId: accountId,
      categoryId: categoryId,
      minAmount: minAmount,
      maxAmount: maxAmount,
      keyword: keyword,
      page: page,
      size: size,
      sort: sort,
    );

    return PaginatedData<Transaction>(
      items: response.items
          .map((TransactionResponse item) => item.toDomain())
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
  Future<Transaction> create({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    final response = await _transactionsApi.create(
      CreateTransactionRequest(
        accountId: accountId,
        categoryId: categoryId,
        type: _transactionTypeToWire(type),
        amount: amount,
        currency: currency,
        description: _normalizeDescription(description),
        transactionDate: _toWireDate(transactionDate),
      ),
    );

    return response.toDomain();
  }

  @override
  Future<Transaction> update({
    required String transactionId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    final response = await _transactionsApi.update(
      transactionId: transactionId,
      request: UpdateTransactionRequest(
        accountId: accountId,
        categoryId: categoryId,
        type: _transactionTypeToWire(type),
        amount: amount,
        currency: currency,
        description: _normalizeDescription(description),
        transactionDate: _toWireDate(transactionDate),
      ),
    );

    return response.toDomain();
  }

  @override
  Future<void> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    await _transactionsApi.createTransfer(
      CreateTransferRequest(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        categoryId: categoryId,
        amount: amount,
        currency: currency,
        description: _normalizeDescription(description),
        transactionDate: _toWireDate(transactionDate),
      ),
    );
  }

  @override
  Future<void> delete(String transactionId) {
    return _transactionsApi.delete(transactionId);
  }
}

String _transactionTypeToWire(TransactionType type) {
  return switch (type) {
    TransactionType.income => 'INCOME',
    TransactionType.expense => 'EXPENSE',
    TransactionType.transfer => 'TRANSFER',
  };
}

String _toWireDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _normalizeDescription(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

@Riverpod(keepAlive: true)
TransactionsRepository transactionsRepository(Ref ref) {
  return TransactionsRepositoryImpl(ref.watch(transactionsApiProvider));
}
