import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/ocr/application/ocr_controller.dart';
import 'package:saveapenny/features/ocr/data/ocr_repository.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/features/ocr/domain/ocr_repository.dart';
import 'package:saveapenny/features/ocr/presentation/ocr_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

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

OcrJob _job({
  OcrJobStatus status = OcrJobStatus.completed,
  List<OcrTransactionCandidate> candidates = const <OcrTransactionCandidate>[],
}) {
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
    transactionCandidates: candidates,
    createdAt: DateTime.parse('2026-07-13T10:00:00Z'),
    updatedAt: DateTime.parse('2026-07-13T10:00:02Z'),
  );
}

Future<void> _pumpWidget(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OcrScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ocr screen shows the idle state', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        ocrRepositoryProvider.overrideWith(
          (ref) => _FakeOcrRepository(
            onSubmit: (_) async => throw UnimplementedError(),
            onStatus: (_) async => throw UnimplementedError(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(tester, container: container);

    expect(find.text('No document selected'), findsOneWidget);
    expect(find.text('Choose document'), findsOneWidget);
  });

  testWidgets('ocr screen shows mapped copy when upload fails', (
    WidgetTester tester,
  ) async {
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
            onStatus: (_) async => throw UnimplementedError(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(tester, container: container);
    await container
        .read(ocrControllerProvider.notifier)
        .submitFile(filePath: '/tmp/bad.txt');
    await tester.pumpAndSettle();

    expect(find.text('No document selected'), findsOneWidget);
    expect(
      find.textContaining('The file is empty, too large, unsupported'),
      findsOneWidget,
    );
  });

  testWidgets('ocr screen shows completed OCR candidates', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        ocrRepositoryProvider.overrideWith(
          (ref) => _FakeOcrRepository(
            onSubmit: (_) async => const OcrSubmitJob(
              jobId: 'ocr-1',
              status: OcrJobStatus.pending,
            ),
            onStatus: (_) async => _job(
              candidates: <OcrTransactionCandidate>[
                OcrTransactionCandidate(
                  date: DateTime.utc(2026, 7, 13),
                  amount: 120.5,
                  description: 'Corner Market',
                  categoryHint: 'FOOD',
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(tester, container: container);
    await container
        .read(ocrControllerProvider.notifier)
        .submitFile(filePath: '/tmp/receipt.png');
    await tester.pumpAndSettle();

    expect(find.text('OCR complete'), findsOneWidget);
    expect(find.text('Transaction candidates'), findsOneWidget);
    expect(find.text('Corner Market'), findsWidgets);
    expect(find.text('Use candidate'), findsOneWidget);
  });
}
