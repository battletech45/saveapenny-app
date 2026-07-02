import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/recurring_transactions/application/recurring_transactions_controller.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';

class _FakeRecurringTransactionsRepository
    implements RecurringTransactionsRepository {
  _FakeRecurringTransactionsRepository({
    this.onList,
    this.onUpcoming,
    this.onCreate,
    this.onPause,
  });

  final Future<PaginatedData<RecurringTransaction>> Function()? onList;
  final Future<List<UpcomingRecurringTransaction>> Function()? onUpcoming;
  final Future<RecurringTransaction> Function({
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  })?
  onCreate;
  final Future<RecurringTransaction> Function(String recurringTransactionId)?
  onPause;

  @override
  Future<RecurringTransaction> create({
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  }) {
    return onCreate!(
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      frequency: frequency,
      nextRunDate: nextRunDate,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      classification: classification,
    );
  }

  @override
  Future<void> delete(String recurringTransactionId) {
    throw UnimplementedError();
  }

  @override
  Future<RecurringTransaction> get(String recurringTransactionId) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedData<RecurringTransactionHistoryEntry>> history(
    String recurringTransactionId, {
    int page = 0,
    int size = 20,
    String sort = 'scheduledDate,desc',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedData<RecurringTransaction>> list({
    int page = 0,
    int size = 20,
    String sort = 'nextRunDate,asc',
  }) {
    return onList!();
  }

  @override
  Future<RecurringTransaction> pause(String recurringTransactionId) {
    return onPause!(recurringTransactionId);
  }

  @override
  Future<RecurringTransaction> resume(String recurringTransactionId) {
    throw UnimplementedError();
  }

  @override
  Future<List<UpcomingRecurringTransaction>> upcoming({int limit = 10}) {
    return onUpcoming!();
  }

  @override
  Future<RecurringTransaction> update({
    required String recurringTransactionId,
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    required RecurringStatus status,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  }) {
    throw UnimplementedError();
  }
}

RecurringTransaction _item({
  required String id,
  required RecurringStatus status,
}) {
  return RecurringTransaction(
    id: id,
    userId: 'u-1',
    accountId: 'a-1',
    categoryId: 'c-1',
    type: RecurringTransactionType.expense,
    amount: 49.99,
    frequency: RecurringFrequency.monthly,
    nextRunDate: DateTime.parse('2026-07-15T00:00:00Z'),
    status: status,
    name: 'Netflix',
    description: 'Streaming',
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

UpcomingRecurringTransaction _upcoming() {
  return UpcomingRecurringTransaction(
    recurringTransactionId: 'r-1',
    name: 'Netflix',
    amount: 49.99,
    scheduledDate: DateTime.parse('2026-07-15T00:00:00Z'),
  );
}

PaginatedData<RecurringTransaction> _page(
  List<RecurringTransaction> items, {
  int page = 0,
  bool hasNext = false,
  bool hasPrevious = false,
}) {
  return PaginatedData<RecurringTransaction>(
    items: items,
    page: page,
    size: 20,
    totalItems: items.length,
    totalPages: hasNext ? page + 2 : page + 1,
    hasNext: hasNext,
    hasPrevious: hasPrevious,
  );
}

void main() {
  test('build loads the first recurring page and upcoming runs', () async {
    final existing = _item(id: 'r-1', status: RecurringStatus.active);

    final container = ProviderContainer(
      overrides: [
        recurringTransactionsRepositoryProvider.overrideWith(
          (ref) => _FakeRecurringTransactionsRepository(
            onList: () async => _page(<RecurringTransaction>[existing]),
            onUpcoming: () async => <UpcomingRecurringTransaction>[_upcoming()],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      recurringTransactionsControllerProvider.future,
    );

    expect(state.items, <RecurringTransaction>[existing]);
    expect(state.upcoming, <UpcomingRecurringTransaction>[_upcoming()]);
  });

  test('create preserves current list when the mutation fails', () async {
    final existing = _item(id: 'r-1', status: RecurringStatus.active);

    final container = ProviderContainer(
      overrides: [
        recurringTransactionsRepositoryProvider.overrideWith(
          (ref) => _FakeRecurringTransactionsRepository(
            onList: () async => _page(<RecurringTransaction>[existing]),
            onUpcoming: () async => <UpcomingRecurringTransaction>[_upcoming()],
            onCreate:
                ({
                  required accountId,
                  required categoryId,
                  required type,
                  required amount,
                  required frequency,
                  required nextRunDate,
                  name,
                  description,
                  startDate,
                  endDate,
                  classification,
                }) async {
                  throw const Failure.api(
                    code: ApiErrorCode.invalidRecurringTransactionNextRunDate,
                    message: 'Invalid next run date.',
                  );
                },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(recurringTransactionsControllerProvider.future);

    await expectLater(
      container
          .read(recurringTransactionsControllerProvider.notifier)
          .create(
            accountId: 'a-1',
            categoryId: 'c-1',
            type: RecurringTransactionType.expense,
            amount: 49.99,
            frequency: RecurringFrequency.monthly,
            nextRunDate: DateTime.parse('2026-06-01T00:00:00Z'),
          ),
      throwsA(isA<ApiFailure>()),
    );

    expect(
      container.read(recurringTransactionsControllerProvider).value?.items,
      <RecurringTransaction>[existing],
    );
  });

  test('pause refreshes the first page after a successful mutation', () async {
    final active = _item(id: 'r-1', status: RecurringStatus.active);
    final paused = active.copyWith(status: RecurringStatus.paused);
    var listCallCount = 0;

    final container = ProviderContainer(
      overrides: [
        recurringTransactionsRepositoryProvider.overrideWith(
          (ref) => _FakeRecurringTransactionsRepository(
            onList: () async {
              listCallCount += 1;
              return listCallCount == 1
                  ? _page(<RecurringTransaction>[active])
                  : _page(<RecurringTransaction>[paused]);
            },
            onUpcoming: () async => <UpcomingRecurringTransaction>[_upcoming()],
            onPause: (recurringTransactionId) async => paused,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(recurringTransactionsControllerProvider.future);
    await container
        .read(recurringTransactionsControllerProvider.notifier)
        .pause('r-1');

    expect(
      container.read(recurringTransactionsControllerProvider).value?.items,
      <RecurringTransaction>[paused],
    );
  });
}
