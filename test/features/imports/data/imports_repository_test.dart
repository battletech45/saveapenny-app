import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/imports/data/imports_api.dart';
import 'package:saveapenny/features/imports/data/imports_repository.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late ImportsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = ImportsRepositoryImpl(ImportsApi(ApiClient(dio)));
  });

  test(
    'preview returns a domain ImportPreview from preview response',
    () async {
      final tempFile = await _createTempCsv();
      addTearDown(tempFile.deleteSync);

      adapter.enqueueJson(
        path: '/imports/transactions/preview',
        statusCode: 201,
        body: <String, dynamic>{
          'success': true,
          'data': <String, dynamic>{
            'importId': 'b-1',
            'fileName': 'transactions.csv',
            'totalRows': 5,
            'validRows': 4,
            'invalidRows': 1,
            'errors': <Map<String, dynamic>>[
              <String, dynamic>{
                'rowNumber': 3,
                'errorMessage': 'Amount must be greater than 0',
                'rawData': 'EXPENSE,2026-06-09,-100.00,USD,acc-uuid,cat-uuid,',
              },
            ],
          },
          'error': null,
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );

      final preview = await repository.preview(filePath: tempFile.path);

      expect(preview.importId, 'b-1');
      expect(preview.fileName, 'transactions.csv');
      expect(preview.totalRows, 5);
      expect(preview.validRows, 4);
      expect(preview.invalidRows, 1);
      expect(preview.errors, hasLength(1));
      expect(preview.errors.first.rowNumber, 3);
      expect(
        preview.errors.first.errorMessage,
        'Amount must be greater than 0',
      );
    },
  );

  test('confirm returns a domain ImportStatus from confirm response', () async {
    adapter.enqueueJson(
      path: '/imports/transactions/confirm',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'importId': 'b-1',
          'status': 'RUNNING',
          'totalRows': 5,
          'importedRows': 0,
          'failedRows': 0,
          'createdAt': '2026-06-09T12:00:00Z',
          'updatedAt': '2026-06-09T12:00:05Z',
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:05Z',
      },
    );

    final status = await repository.confirm(importId: 'b-1');

    expect(status.importId, 'b-1');
    expect(status.status, ImportJobStatus.running);
    expect(status.totalRows, 5);
    expect(status.importedRows, 0);
  });

  test('status returns completed status', () async {
    adapter.enqueueJson(
      path: '/imports/transactions/b-1/status',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'importId': 'b-1',
          'status': 'COMPLETED',
          'totalRows': 5,
          'importedRows': 4,
          'failedRows': 1,
          'createdAt': '2026-06-09T12:00:00Z',
          'updatedAt': '2026-06-09T12:00:10Z',
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:10Z',
      },
    );

    final status = await repository.status(importId: 'b-1');

    expect(status.status, ImportJobStatus.completed);
    expect(status.importedRows, 4);
    expect(status.failedRows, 1);
  });

  test('throws ApiFailure on validation error', () async {
    adapter.enqueueJson(
      path: '/imports/transactions/confirm',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'IMPORT_NOT_FOUND',
          'message': 'Import not found',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.confirm(importId: 'not-found'),
      throwsA(
        isA<ApiFailure>().having(
          (f) => f.code,
          'code',
          ApiErrorCode.importNotFound,
        ),
      ),
    );
  });
}

Future<File> _createTempCsv() async {
  final file = File(
    '${Directory.systemTemp.path}/test_import_${DateTime.now().millisecondsSinceEpoch}.csv',
  );
  await file.writeAsString(
    'type,date,amount,currency,account,category,description\n',
  );
  return file;
}
