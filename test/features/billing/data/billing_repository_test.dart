import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/billing/data/billing_api.dart';
import 'package:saveapenny/features/billing/data/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late BillingRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
      ..httpClientAdapter = adapter;
    repository = BillingRepositoryImpl(BillingApi(ApiClient(dio)));
  });

  Map<String, dynamic> entitlementJson({String plan = 'plus'}) =>
      <String, dynamic>{
        'plan': plan,
        'status': 'active',
        'isActive': true,
        'willRenew': true,
        'expiresAt': '2026-08-14T10:00:00Z',
        'trialEndsAt': null,
        'features': <String, dynamic>{
          'assistant': true,
          'insights': true,
          'stocks': true,
          'ocr': true,
          'csvImport': true,
          'reportExport': true,
          'advancedRecurring': true,
          'goalWhatIf': true,
        },
        'limits': <String, dynamic>{
          'activeBudgets': 4,
          'maxActiveBudgets': null,
          'activeGoals': 2,
          'maxActiveGoals': null,
          'reportHistoryMonths': 24,
        },
      };

  test('getEntitlement maps the entitlement payload', () async {
    adapter.enqueueJson(
      path: '/billing/entitlement',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': entitlementJson(),
        'error': null,
        'timestamp': '2026-07-14T10:00:00Z',
      },
    );

    final entitlement = await repository.getEntitlement();

    expect(entitlement.plan, Plan.plus);
    expect(entitlement.status, EntitlementStatus.active);
    expect(entitlement.isActive, isTrue);
    expect(entitlement.features.assistant, isTrue);
    expect(entitlement.limits.reportHistoryMonths, 24);
  });

  test('sync maps the refreshed entitlement payload', () async {
    adapter.enqueueJson(
      path: '/billing/sync',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': entitlementJson(plan: 'free'),
        'error': null,
        'timestamp': '2026-07-14T10:00:00Z',
      },
    );

    final entitlement = await repository.sync();

    expect(entitlement.plan, Plan.free);
  });

  test('getEntitlement throws typed failure on error envelope', () async {
    adapter.enqueueJson(
      path: '/billing/entitlement',
      statusCode: 401,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'UNAUTHORIZED',
          'message': 'Session expired.',
          'details': <String>[],
        },
        'timestamp': '2026-07-14T10:00:00Z',
      },
    );

    await expectLater(
      repository.getEntitlement(),
      throwsA(isA<UnauthenticatedFailure>()),
    );
  });

  test('sync surfaces plan-restricted failures with the right code', () async {
    adapter.enqueueJson(
      path: '/billing/sync',
      statusCode: 403,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'PLUS_REQUIRED',
          'message': 'Upgrade required.',
          'details': <String>[],
        },
        'timestamp': '2026-07-14T10:00:00Z',
      },
    );

    await expectLater(
      repository.sync(),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.plusRequired,
        ),
      ),
    );
  });
}
