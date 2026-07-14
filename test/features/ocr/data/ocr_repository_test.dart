import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/config/app_environment.dart';
import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/ocr/data/ocr_api.dart';
import 'package:saveapenny/features/ocr/data/ocr_repository.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late OcrRepositoryImpl repository;
  late File uploadFile;

  setUp(() async {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = OcrRepositoryImpl(
      OcrApi(ApiClient(dio), AppEnvironment.current()),
    );
    final directory = await Directory.systemTemp.createTemp('ocr-test');
    uploadFile = File('${directory.path}/receipt.png');
    await uploadFile.writeAsString('fake image bytes');
  });

  test('submit maps the OCR submit response', () async {
    adapter.enqueueJson(
      path: 'http://localhost:8080/api/imports/ocr',
      statusCode: 202,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'jobId': 'ocr-1', 'status': 'PENDING'},
        'error': null,
        'timestamp': '2026-07-13T10:00:00Z',
      },
    );

    final response = await repository.submit(filePath: uploadFile.path);

    expect(response.jobId, 'ocr-1');
    expect(response.status, OcrJobStatus.pending);
  });

  test('status maps completed OCR job details', () async {
    adapter.enqueueJson(
      path: 'http://localhost:8080/api/imports/ocr/ocr-1',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'jobId': 'ocr-1',
          'status': 'COMPLETED',
          'originalFileName': 'receipt.png',
          'errorMessage': null,
          'resultSnippet': 'TOTAL 120.50',
          'rawText': 'TOTAL 120.50\nDATE 2026-07-13',
          'documentType': 'RETAIL_RECEIPT',
          'currency': 'TRY',
          'merchantName': 'Corner Market',
          'paymentDate': '2026-07-13',
          'issueDate': '2026-07-13',
          'extractedDates': <String>['2026-07-13'],
          'extractedAmounts': <double>[120.5],
          'referenceNumbers': <String>['A-1'],
          'labels': <String>['TOTAL'],
          'parseConfidence': 0.91,
          'parseWarning': null,
          'parseDiagnostics': <String, dynamic>{
            'detectedDocumentType': 'RETAIL_RECEIPT',
            'confidenceScore': 0.91,
            'warnings': <String>['Low resolution'],
            'notes': <String>['Used total line'],
            'selectedCandidateReason': 'Closest amount/date pair',
            'noCandidateReason': null,
          },
          'transactionCandidates': <Map<String, dynamic>>[
            <String, dynamic>{
              'date': '2026-07-13',
              'amount': 120.5,
              'description': 'Corner Market',
              'categoryHint': 'FOOD',
            },
          ],
          'createdAt': '2026-07-13T10:00:00Z',
          'updatedAt': '2026-07-13T10:00:02Z',
        },
        'error': null,
        'timestamp': '2026-07-13T10:00:02Z',
      },
    );

    final response = await repository.status(jobId: 'ocr-1');

    expect(response.status, OcrJobStatus.completed);
    expect(response.originalFileName, 'receipt.png');
    expect(response.transactionCandidates, hasLength(1));
    expect(response.transactionCandidates.single.categoryHint, 'FOOD');
    expect(response.parseDiagnostics?.warnings.single, 'Low resolution');
  });

  test('submit throws typed failure on backend file error', () async {
    adapter.enqueueJson(
      path: 'http://localhost:8080/api/imports/ocr',
      statusCode: 400,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'INVALID_OCR_FILE',
          'message': 'Unsupported file.',
          'details': <String>[],
        },
        'timestamp': '2026-07-13T10:00:00Z',
      },
    );

    await expectLater(
      repository.submit(filePath: uploadFile.path),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.invalidOcrFile,
        ),
      ),
    );
  });
}
