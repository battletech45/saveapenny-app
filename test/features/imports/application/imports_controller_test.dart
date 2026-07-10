import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/imports/application/imports_controller.dart';
import 'package:saveapenny/features/imports/data/imports_repository.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';
import 'package:saveapenny/features/imports/domain/imports_repository.dart';

class _FakeImportsRepository implements ImportsRepository {
  _FakeImportsRepository({this.onPreview, this.onConfirm, this.onStatus});

  final Future<ImportPreview> Function(String filePath)? onPreview;
  final Future<ImportStatus> Function(String importId)? onConfirm;
  final Future<ImportStatus> Function(String importId)? onStatus;

  @override
  Future<ImportPreview> preview({required String filePath}) {
    return onPreview!(filePath);
  }

  @override
  Future<ImportStatus> confirm({required String importId}) {
    return onConfirm!(importId);
  }

  @override
  Future<ImportStatus> status({required String importId}) {
    return onStatus!(importId);
  }
}

ImportPreview _preview({
  String importId = 'imp-1',
  int totalRows = 5,
  int validRows = 4,
  int invalidRows = 1,
}) {
  return ImportPreview(
    importId: importId,
    fileName: 'test.csv',
    totalRows: totalRows,
    validRows: validRows,
    invalidRows: invalidRows,
    errors: invalidRows > 0
        ? <ImportPreviewRowError>[
            const ImportPreviewRowError(
              rowNumber: 3,
              errorMessage: 'Amount must be greater than 0',
              rawData: 'EXPENSE,2026-06-09,-100.00,USD,acc-uuid,cat-uuid,',
            ),
          ]
        : const <ImportPreviewRowError>[],
  );
}

ImportStatus _status({
  String importId = 'imp-1',
  ImportJobStatus status = ImportJobStatus.completed,
  int totalRows = 5,
  int importedRows = 4,
  int failedRows = 1,
}) {
  return ImportStatus(
    importId: importId,
    status: status,
    totalRows: totalRows,
    importedRows: importedRows,
    failedRows: failedRows,
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:10Z'),
  );
}

void main() {
  test(
    'previewFile transitions from idle to previewReady on success',
    () async {
      final container = ProviderContainer(
        overrides: [
          importsRepositoryProvider.overrideWith(
            (ref) => _FakeImportsRepository(onPreview: (_) async => _preview()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(importsControllerProvider.notifier)
          .previewFile(filePath: 'test.csv');

      final state = container.read(importsControllerProvider);
      expect(state.isPreviewReady, isTrue);
      expect(state.preview, isNotNull);
      expect(state.preview!.validRows, 4);
    },
  );

  test('previewFile sets error on ApiFailure', () async {
    final container = ProviderContainer(
      overrides: [
        importsRepositoryProvider.overrideWith(
          (ref) => _FakeImportsRepository(
            onPreview: (_) async {
              throw const Failure.api(
                code: ApiErrorCode.invalidImportFile,
                message: 'Invalid file',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(importsControllerProvider.notifier)
        .previewFile(filePath: 'bad.csv');

    final state = container.read(importsControllerProvider);
    expect(state.isIdle, isTrue);
    expect(state.error, isA<ApiFailure>());
  });

  test('confirmImport transitions from previewReady to completed', () async {
    final container = ProviderContainer(
      overrides: [
        importsRepositoryProvider.overrideWith(
          (ref) => _FakeImportsRepository(
            onPreview: (_) async => _preview(),
            onConfirm: (_) async => _status(status: ImportJobStatus.completed),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(importsControllerProvider.notifier)
        .previewFile(filePath: 'test.csv');
    await container.read(importsControllerProvider.notifier).confirmImport();

    final state = container.read(importsControllerProvider);
    expect(state.isCompleted, isTrue);
    expect(state.status!.importedRows, 4);
  });

  test('confirmImport surfaces polling failures instead of staying stuck', () async {
    final container = ProviderContainer(
      overrides: [
        importsRepositoryProvider.overrideWith(
          (ref) => _FakeImportsRepository(
            onPreview: (_) async => _preview(),
            onConfirm: (_) async =>
                _status(status: ImportJobStatus.running, importedRows: 0),
            onStatus: (_) async {
              throw const Failure.network();
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(importsControllerProvider.notifier)
        .previewFile(filePath: 'test.csv');
    await container.read(importsControllerProvider.notifier).confirmImport();
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    final state = container.read(importsControllerProvider);
    expect(state.isConfirming, isTrue);
    expect(state.error, isA<NetworkFailure>());
  });

  test('reset returns to idle state', () async {
    final container = ProviderContainer(
      overrides: [
        importsRepositoryProvider.overrideWith(
          (ref) => _FakeImportsRepository(onPreview: (_) async => _preview()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(importsControllerProvider.notifier)
        .previewFile(filePath: 'test.csv');
    container.read(importsControllerProvider.notifier).reset();

    final state = container.read(importsControllerProvider);
    expect(state.isIdle, isTrue);
    expect(state.preview, isNull);
  });
}
