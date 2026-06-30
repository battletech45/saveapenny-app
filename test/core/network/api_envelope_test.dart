import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';

void main() {
  group('ApiEnvelope', () {
    test('parses a success envelope into typed data', () {
      final envelope = ApiEnvelope<String>.fromJson(<String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'name': 'SaveAPenny'},
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      }, (data) => (data as Map<String, dynamic>)['name'] as String);

      expect(envelope.success, isTrue);
      expect(envelope.requireData, 'SaveAPenny');
      expect(envelope.error, isNull);
      expect(envelope.timestamp, DateTime.parse('2026-06-09T12:00:00Z'));
    });

    test('parses an error envelope into a typed api error', () {
      final envelope = ApiEnvelope<Object?>.fromJson(<String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'VALIDATION_FAILED',
          'message': 'Invalid field',
          'details': <String>['amount: must not be null'],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      }, (data) => data);

      expect(envelope.isError, isTrue);
      expect(envelope.error, isNotNull);
      expect(envelope.error!.code, ApiErrorCode.validationFailed);
      expect(envelope.error!.details, <String>['amount: must not be null']);
    });
  });

  group('PaginatedData', () {
    test('parses paginated payloads', () {
      final page = PaginatedData<String>.fromJson(<String, dynamic>{
        'items': <String>['a', 'b'],
        'page': 0,
        'size': 20,
        'totalItems': 2,
        'totalPages': 1,
        'hasNext': false,
        'hasPrevious': false,
      }, (item) => item as String);

      expect(page.items, <String>['a', 'b']);
      expect(page.totalItems, 2);
      expect(page.hasNext, isFalse);
    });
  });
}
