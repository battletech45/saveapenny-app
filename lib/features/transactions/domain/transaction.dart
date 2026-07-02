import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

enum TransactionType { income, expense, transfer }

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;
}
