import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';
import 'package:saveapenny/features/imports/application/imports_controller.dart';
import 'package:saveapenny/features/imports/data/imports_repository.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';
import 'package:saveapenny/features/imports/domain/imports_repository.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({required this.onList});

  final Future<List<Account>> Function() onList;

  @override
  Future<DateTime?> lastSyncedAt() async => null;

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(String accountId) => throw UnimplementedError();

  @override
  Future<List<Account>> list() => onList();

  @override
  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) => throw UnimplementedError();
}

Account _account({required String id, required num balance}) {
  return Account(
    id: id,
    name: 'Credit card',
    type: AccountType.credit,
    currency: 'TRY',
    balance: balance,
    initialBalance: 0,
    active: true,
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

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

  test(
    'confirmImport syncs accounts once the job completes immediately',
    () async {
      var accountListCallCount = 0;

      final container = ProviderContainer(
        overrides: [
          importsRepositoryProvider.overrideWith(
            (ref) => _FakeImportsRepository(
              onPreview: (_) async => _preview(),
              onConfirm: (_) async =>
                  _status(status: ImportJobStatus.completed),
            ),
          ),
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(
              onList: () async {
                accountListCallCount += 1;
                return accountListCallCount == 1
                    ? <Account>[_account(id: 'a-1', balance: 100)]
                    : <Account>[_account(id: 'a-1', balance: 400)];
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(accountsControllerProvider.future);
      await container
          .read(importsControllerProvider.notifier)
          .previewFile(filePath: 'test.csv');
      await container.read(importsControllerProvider.notifier).confirmImport();

      expect(container.read(accountsControllerProvider).value, <Account>[
        _account(id: 'a-1', balance: 400),
      ]);
    },
  );

  test(
    'confirmImport syncs accounts once background polling completes',
    () async {
      var accountListCallCount = 0;

      final container = ProviderContainer(
        overrides: [
          importsRepositoryProvider.overrideWith(
            (ref) => _FakeImportsRepository(
              onPreview: (_) async => _preview(),
              onConfirm: (_) async =>
                  _status(status: ImportJobStatus.running, importedRows: 0),
              onStatus: (_) async => _status(status: ImportJobStatus.completed),
            ),
          ),
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(
              onList: () async {
                accountListCallCount += 1;
                return accountListCallCount == 1
                    ? <Account>[_account(id: 'a-1', balance: 100)]
                    : <Account>[_account(id: 'a-1', balance: 400)];
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(accountsControllerProvider.future);
      await container
          .read(importsControllerProvider.notifier)
          .previewFile(filePath: 'test.csv');
      await container.read(importsControllerProvider.notifier).confirmImport();
      await Future<void>.delayed(const Duration(seconds: 3));

      expect(container.read(accountsControllerProvider).value, <Account>[
        _account(id: 'a-1', balance: 400),
      ]);
    },
  );

  test(
    'confirmImport surfaces polling failures instead of staying stuck',
    () async {
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
    },
  );

  test(
    'a slow status check does not overlap with the next poll tick',
    () async {
      var statusCallCount = 0;
      var accountListCallCount = 0;

      final container = ProviderContainer(
        overrides: [
          importsRepositoryProvider.overrideWith(
            (ref) => _FakeImportsRepository(
              onPreview: (_) async => _preview(),
              onConfirm: (_) async =>
                  _status(status: ImportJobStatus.running, importedRows: 0),
              onStatus: (_) async {
                statusCallCount += 1;
                // Slower than the 2s poll interval: if Timer.periodic were
                // still in use, a second tick would fire while this is
                // in flight and re-enter _pollStatus.
                await Future<void>.delayed(const Duration(seconds: 3));
                return _status(status: ImportJobStatus.completed);
              },
            ),
          ),
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(
              onList: () async {
                accountListCallCount += 1;
                return <Account>[_account(id: 'a-1', balance: 400)];
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(accountsControllerProvider.future);
      final baselineAccountListCalls = accountListCallCount;
      await container
          .read(importsControllerProvider.notifier)
          .previewFile(filePath: 'test.csv');
      await container.read(importsControllerProvider.notifier).confirmImport();
      await Future<void>.delayed(const Duration(seconds: 6));

      expect(statusCallCount, 1);
      expect(accountListCallCount - baselineAccountListCalls, 1);
      expect(container.read(importsControllerProvider).isCompleted, isTrue);
    },
  );

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
