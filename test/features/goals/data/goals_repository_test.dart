import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/goals/data/goals_api.dart';
import 'package:saveapenny/features/goals/data/goals_repository.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late GoalsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = GoalsRepositoryImpl(GoalsApi(ApiClient(dio)));
  });

  test('lists goals and maps enum values', () async {
    adapter.enqueueJson(
      path: '/goals',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'g-1',
              'type': 'SAVINGS',
              'title': 'Emergency fund',
              'targetAmount': 10000,
              'currency': 'USD',
              'targetDate': '2027-12-31T00:00:00.000',
              'linkedAccountId': null,
              'status': 'ACTIVE',
              'inputs': <String, dynamic>{
                'monthlyContribution': 350,
                'startBalance': 1500,
              },
              'createdAt': '2026-06-09T12:00:00Z',
              'updatedAt': '2026-06-09T12:00:00Z',
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
    expect(page.items.single.type, GoalType.savings);
    expect(page.items.single.status, GoalStatus.active);
  });

  test('lists goal runs and maps feasibility and trigger values', () async {
    adapter.enqueueJson(
      path: '/goals/g-1/runs',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'r-1',
              'goalId': 'g-1',
              'scenarioId': null,
              'inputsSnapshot': <String, dynamic>{'monthlyContribution': 350},
              'outputSummary': <String, dynamic>{'projectedAmount': 10100},
              'outputSeries': <String, dynamic>{'points': <Object>[]},
              'feasibility': 'ON_TRACK',
              'triggeredBy': 'USER',
              'createdAt': '2026-06-09T12:00:00Z',
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

    final page = await repository.listRuns('g-1');

    expect(page.items.single.feasibility, GoalFeasibility.onTrack);
    expect(page.items.single.triggeredBy, GoalRunTrigger.user);
  });

  test('update status surfaces invalid transition failures', () async {
    adapter.enqueueJson(
      path: '/goals/g-1/status',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'INVALID_GOAL_STATUS_TRANSITION',
          'message': 'Invalid status transition',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () =>
          repository.updateStatus(goalId: 'g-1', status: GoalStatus.abandoned),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.invalidGoalStatusTransition,
        ),
      ),
    );
  });
}
