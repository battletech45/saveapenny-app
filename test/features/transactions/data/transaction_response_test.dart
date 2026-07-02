import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/features/transactions/data/dto/transaction_response.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';

void main() {
  test('toDomain maps supported wire transaction types', () {
    final response = TransactionResponse(
      id: 't-1',
      userId: 'u-1',
      accountId: 'a-1',
      categoryId: 'c-1',
      type: 'INCOME',
      amount: 500,
      currency: 'TRY',
      description: 'Salary',
      transactionDate: DateTime.parse('2026-06-09T00:00:00Z'),
      createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
      updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
    );

    final transaction = response.toDomain();

    expect(transaction.type, TransactionType.income);
  });

  test('toDomain rejects unsupported wire transaction types', () {
    final response = TransactionResponse(
      id: 't-1',
      userId: 'u-1',
      accountId: 'a-1',
      categoryId: 'c-1',
      type: 'REFUND',
      amount: 500,
      currency: 'TRY',
      description: 'Salary',
      transactionDate: DateTime.parse('2026-06-09T00:00:00Z'),
      createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
      updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
    );

    expect(response.toDomain, throwsFormatException);
  });
}
