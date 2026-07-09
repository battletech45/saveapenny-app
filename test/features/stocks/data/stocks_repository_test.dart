import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/stocks/data/stocks_api.dart';
import 'package:saveapenny/features/stocks/data/stocks_repository.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late StocksRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = StocksRepositoryImpl(StocksApi(ApiClient(dio)));
  });

  test('lists holdings and maps nullable market fields', () async {
    adapter.enqueueJson(
      path: '/stocks/holdings',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'h-1',
              'symbol': 'IBM',
              'quantity': '7.14285714',
              'purchasePrice': '140.0000',
              'currency': 'USD',
              'purchaseDate': '2025-04-25',
              'notes': 'First position',
              'investedAmount': '1000.00',
              'currentPrice': null,
              'currentValue': null,
              'profitLoss': null,
              'profitLossPercent': null,
              'latestTradingDay': null,
              'createdAt': '2026-06-09T12:00:00Z',
              'updatedAt': '2026-06-10T12:00:00Z',
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

    final page = await repository.listHoldings();

    expect(page.items, hasLength(1));
    expect(page.items.single.symbol, 'IBM');
    expect(page.items.single.quantity, 7.14285714);
    expect(page.items.single.currentPrice, isNull);
  });

  test('create holding surfaces duplicate holding failures', () async {
    adapter.enqueueJson(
      path: '/stocks/holdings',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'DUPLICATE_STOCK_HOLDING',
          'message': 'Duplicate holding.',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.createHolding(
        symbol: 'IBM',
        quantity: 1,
        purchasePrice: 140,
        currency: 'USD',
        purchaseDate: DateTime.parse('2025-04-25T00:00:00Z'),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.duplicateStockHolding,
        ),
      ),
    );
  });
}
