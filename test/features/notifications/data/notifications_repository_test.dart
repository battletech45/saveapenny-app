import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/notifications/data/notifications_api.dart';
import 'package:saveapenny/features/notifications/data/notifications_repository.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late NotificationsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = NotificationsRepositoryImpl(NotificationsApi(ApiClient(dio)));
  });

  test('lists notifications and maps type values', () async {
    adapter.enqueueJson(
      path: '/notifications',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'n-1',
              'userId': 'u-1',
              'type': 'BUDGET_WARNING',
              'title': 'Budget alert',
              'message': 'You are nearing your limit.',
              'metadata': null,
              'read': false,
              'createdAt': '2026-06-09T12:00:00.000Z',
              'updatedAt': '2026-06-09T12:00:00.000Z',
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

    final page = await repository.list();

    expect(page.items, hasLength(1));
    expect(page.items.single.type, NotificationType.budgetWarning);
    expect(page.items.single.title, 'Budget alert');
    expect(page.items.single.read, false);
  });

  test('unreadCount maps response value', () async {
    adapter.enqueueJson(
      path: '/notifications/unread-count',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'unreadCount': 7},
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final count = await repository.unreadCount();

    expect(count, 7);
  });

  test('markRead maps response and sets read flag', () async {
    adapter.enqueueJson(
      path: '/notifications/n-1',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'id': 'n-1',
          'userId': 'u-1',
          'type': 'SYSTEM',
          'title': 'System notice',
          'message': 'Scheduled maintenance.',
          'metadata': null,
          'read': true,
          'createdAt': '2026-06-09T12:00:00.000Z',
          'updatedAt': '2026-06-09T12:00:00.000Z',
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final notification = await repository.markRead('n-1');

    expect(notification.read, true);
    expect(notification.type, NotificationType.system);
  });

  test('markRead surfaces resource not found failures', () async {
    adapter.enqueueJson(
      path: '/notifications/n-1',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'RESOURCE_NOT_FOUND',
          'message': 'Notification not found.',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.markRead('n-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.resourceNotFound,
        ),
      ),
    );
  });

  test('delete surfaces resource not found failures', () async {
    adapter.enqueueJson(
      path: '/notifications/n-1',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'RESOURCE_NOT_FOUND',
          'message': 'Notification not found.',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.delete('n-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.resourceNotFound,
        ),
      ),
    );
  });
}
