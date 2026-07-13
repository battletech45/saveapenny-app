import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/ocr/application/ocr_controller.dart';
import 'package:saveapenny/features/ocr/data/ocr_repository.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/features/ocr/domain/ocr_repository.dart';

class _FakeOcrRepository implements OcrRepository {
  _FakeOcrRepository({this.onSubmit, this.onStatus});

  final Future<OcrSubmitJob> Function(String filePath)? onSubmit;
  final Future<OcrJob> Function(String jobId)? onStatus;

  @override
  Future<OcrJob> status({required String jobId}) => onStatus!(jobId);

  @override
  Future<OcrSubmitJob> submit({required String filePath}) =>
      onSubmit!(filePath);
}

OcrJob _job({OcrJobStatus status = OcrJobStatus.completed}) {
  return OcrJob(
    jobId: 'ocr-1',
    status: status,
    originalFileName: 'receipt.png',
    errorMessage: status == OcrJobStatus.failed ? 'OCR failed.' : null,
    resultSnippet: 'TOTAL 120.50',
    rawText: 'TOTAL 120.50',
    documentType: 'RETAIL_RECEIPT',
    currency: 'TRY',
    merchantName: 'Corner Market',
    paymentDate: DateTime.utc(2026, 7, 13),
    issueDate: DateTime.utc(2026, 7, 13),
    extractedDates: <DateTime>[DateTime.utc(2026, 7, 13)],
    extractedAmounts: const <num>[120.5],
    referenceNumbers: const <String>['A-1'],
    labels: const <String>['TOTAL'],
    parseConfidence: 0.91,
    parseWarning: null,
    parseDiagnostics: const OcrParseDiagnostics(),
    transactionCandidates: const <OcrTransactionCandidate>[],
    createdAt: DateTime.parse('2026-07-13T10:00:00Z'),
    updatedAt: DateTime.parse('2026-07-13T10:00:02Z'),
  );
}

void main() {
  test(
    'submitFile reaches completed state when OCR status completes',
    () async {
      final container = ProviderContainer(
        overrides: [
          ocrRepositoryProvider.overrideWith(
            (ref) => _FakeOcrRepository(
              onSubmit: (_) async => const OcrSubmitJob(
                jobId: 'ocr-1',
                status: OcrJobStatus.pending,
              ),
              onStatus: (_) async => _job(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(ocrControllerProvider.notifier)
          .submitFile(filePath: '/tmp/receipt.png');

      final state = container.read(ocrControllerProvider);
      expect(state.isCompleted, isTrue);
      expect(state.job?.merchantName, 'Corner Market');
    },
  );

  test(
    'submitFile stores file error and returns to idle on invalid upload',
    () async {
      final container = ProviderContainer(
        overrides: [
          ocrRepositoryProvider.overrideWith(
            (ref) => _FakeOcrRepository(
              onSubmit: (_) async {
                throw const Failure.api(
                  code: ApiErrorCode.invalidOcrFile,
                  message: 'Bad file.',
                );
              },
              onStatus: (_) async => _job(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(ocrControllerProvider.notifier)
          .submitFile(filePath: '/tmp/bad.txt');

      final state = container.read(ocrControllerProvider);
      expect(state.isIdle, isTrue);
      expect(state.error, isA<ApiFailure>());
    },
  );

  test(
    'submitFile surfaces polling failure while staying in polling state',
    () async {
      final container = ProviderContainer(
        overrides: [
          ocrRepositoryProvider.overrideWith(
            (ref) => _FakeOcrRepository(
              onSubmit: (_) async => const OcrSubmitJob(
                jobId: 'ocr-1',
                status: OcrJobStatus.pending,
              ),
              onStatus: (_) async {
                throw const Failure.network();
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(ocrControllerProvider.notifier)
          .submitFile(filePath: '/tmp/receipt.png');

      final state = container.read(ocrControllerProvider);
      expect(state.isPolling, isTrue);
      expect(state.error, isA<NetworkFailure>());
    },
  );
}
