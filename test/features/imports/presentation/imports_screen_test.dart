import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/imports/application/imports_controller.dart';
import 'package:saveapenny/features/imports/data/imports_repository.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';
import 'package:saveapenny/features/imports/domain/imports_repository.dart';
import 'package:saveapenny/features/imports/presentation/imports_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeImportsRepository implements ImportsRepository {
  _FakeImportsRepository({this.onPreview, this.onConfirm});

  final Future<ImportPreview> Function({required String filePath})? onPreview;
  final Future<ImportStatus> Function({required String importId})? onConfirm;

  @override
  Future<ImportPreview> preview({required String filePath}) {
    return onPreview!(filePath: filePath);
  }

  @override
  Future<ImportStatus> confirm({required String importId}) {
    return onConfirm!(importId: importId);
  }

  @override
  Future<ImportStatus> status({required String importId}) {
    throw UnimplementedError();
  }
}

ImportPreview _preview({int validRows = 3, int invalidRows = 0}) {
  return ImportPreview(
    importId: 'imp-1',
    fileName: 'transactions.csv',
    totalRows: validRows + invalidRows,
    validRows: validRows,
    invalidRows: invalidRows,
    errors: const <ImportPreviewRowError>[],
  );
}

ImportStatus _status(ImportJobStatus jobStatus) {
  return ImportStatus(
    importId: 'imp-1',
    status: jobStatus,
    totalRows: 3,
    importedRows: jobStatus == ImportJobStatus.completed ? 3 : 0,
    failedRows: jobStatus == ImportJobStatus.failed ? 3 : 0,
    createdAt: DateTime.parse('2026-06-09T00:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T00:05:00Z'),
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
        home: const ImportsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('imports screen shows preview stats after a successful preview', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        importsRepositoryProvider.overrideWith(
          (ref) => _FakeImportsRepository(
            onPreview: ({required filePath}) async =>
                _preview(validRows: 3, invalidRows: 1),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(tester, container: container);
    await container
        .read(importsControllerProvider.notifier)
        .previewFile(filePath: 'transactions.csv');
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('imports screen shows mapped copy when preview fails', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        importsRepositoryProvider.overrideWith(
          (ref) => _FakeImportsRepository(
            onPreview: ({required filePath}) async {
              throw const Failure.api(
                code: ApiErrorCode.invalidImportFile,
                message: 'Bad file.',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(tester, container: container);
    await container
        .read(importsControllerProvider.notifier)
        .previewFile(filePath: 'bad.csv');
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.importsInvalidFileError), findsOneWidget);
  });

  testWidgets('imports screen shows completed summary after confirm succeeds', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        importsRepositoryProvider.overrideWith(
          (ref) => _FakeImportsRepository(
            onPreview: ({required filePath}) async => _preview(),
            onConfirm: ({required importId}) async =>
                _status(ImportJobStatus.completed),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(tester, container: container);
    await container
        .read(importsControllerProvider.notifier)
        .previewFile(filePath: 'transactions.csv');
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(
      find.widgetWithText(ElevatedButton, l10n.importsConfirmCta),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(ElevatedButton, l10n.importsConfirmCta).last,
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.importsCompletedTitle), findsOneWidget);
  });
}
