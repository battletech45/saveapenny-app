import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';

abstract interface class TransactionsRepository {
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
  });

  Future<Transaction> create({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  });

  Future<Transaction> update({
    required String transactionId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  });

  Future<void> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  });

  Future<void> delete(String transactionId);
}
