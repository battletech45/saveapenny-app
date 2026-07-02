import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/transactions/domain/transaction.dart';

part 'transaction_response.freezed.dart';
part 'transaction_response.g.dart';

@freezed
abstract class TransactionResponse with _$TransactionResponse {
  const factory TransactionResponse({
    required String id,
    required String userId,
    required String accountId,
    required String categoryId,
    required String type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionResponse;

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseFromJson(json);
}

extension TransactionResponseX on TransactionResponse {
  Transaction toDomain() {
    return Transaction(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      type: _transactionTypeFromWire(type),
      amount: amount,
      currency: currency,
      description: description,
      transactionDate: transactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

TransactionType _transactionTypeFromWire(String value) {
  return switch (value.toUpperCase()) {
    'INCOME' => TransactionType.income,
    'EXPENSE' => TransactionType.expense,
    'TRANSFER' => TransactionType.transfer,
    _ => throw FormatException('Unsupported transaction type: $value'),
  };
}
