import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';

void main() {
  group('FailureMapper.fromApiError', () {
    test('maps auth expiry codes to unauthenticated failure', () {
      final failure = FailureMapper.fromApiError(
        ApiError(
          code: ApiErrorCode.invalidRefreshToken,
          rawCode: 'INVALID_REFRESH_TOKEN',
          message: 'expired',
          details: const <String>[],
        ),
      );

      expect(failure, isA<UnauthenticatedFailure>());
    });

    test('maps rate-limited codes to rate-limited failure', () {
      final failure = FailureMapper.fromApiError(
        ApiError(
          code: ApiErrorCode.rateLimited,
          rawCode: 'RATE_LIMITED',
          message: 'slow down',
          details: const <String>[],
        ),
      );

      expect(failure, isA<RateLimitedFailure>());
    });
  });

  group('FailureMapper.fromDio', () {
    test('maps retry-after header on 429 responses', () {
      final failure = FailureMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/reports'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/reports'),
            statusCode: 429,
            headers: Headers.fromMap(<String, List<String>>{
              'retry-after': <String>['12'],
            }),
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(failure, isA<RateLimitedFailure>());
      expect(
        (failure as RateLimitedFailure).retryAfter,
        const Duration(seconds: 12),
      );
    });

    test('maps timeout errors to network failure', () {
      final failure = FailureMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/reports'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(failure, isA<NetworkFailure>());
    });
  });
}
