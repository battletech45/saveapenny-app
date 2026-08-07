import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/credit_cards/data/credit_cards_api.dart';
import 'package:saveapenny/features/credit_cards/data/credit_cards_repository.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late CreditCardsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = CreditCardsRepositoryImpl(CreditCardsApi(ApiClient(dio)));
  });

  test('lists statements from the paginated payload', () async {
    adapter.enqueueJson(
      path: '/accounts/acc-1/credit/statements',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'st-1',
              'accountId': 'acc-1',
              'statementDate': '2026-06-01',
              'dueDate': '2026-06-22',
              'previousBalance': 100,
              'newBalance': 250,
              'interestCharged': 5,
              'minimumPaymentDue': 25,
              'amountPaid': 0,
              'status': 'OPEN',
            },
          ],
          'page': 0,
          'size': 20,
          'totalItems': 1,
          'totalPages': 1,
          'hasNext': false,
          'hasPrevious': false,
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final page = await repository.listStatements(accountId: 'acc-1');

    expect(page.items, hasLength(1));
    expect(page.items.first.newBalance, 250);
    expect(page.hasNext, isFalse);
  });

  test(
    'makePayment surfaces INVALID_CREDIT_CARD_PAYMENT as an ApiFailure',
    () async {
      adapter.enqueueJson(
        path: '/accounts/acc-1/credit/payments',
        statusCode: 200,
        body: <String, dynamic>{
          'success': false,
          'data': null,
          'error': <String, dynamic>{
            'code': 'INVALID_CREDIT_CARD_PAYMENT',
            'message': 'Amount exceeds the outstanding balance.',
            'details': <String>[],
          },
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );

      await expectLater(
        () => repository.makePayment(
          accountId: 'acc-1',
          sourceAccountId: 'acc-2',
          paymentType: CreditCardPaymentType.custom,
          amount: 999999,
        ),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.code,
            'code',
            ApiErrorCode.invalidCreditCardPayment,
          ),
        ),
      );
    },
  );
}
