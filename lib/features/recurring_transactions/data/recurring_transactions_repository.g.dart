// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transactions_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringTransactionsRepository)
final recurringTransactionsRepositoryProvider =
    RecurringTransactionsRepositoryProvider._();

final class RecurringTransactionsRepositoryProvider
    extends
        $FunctionalProvider<
          RecurringTransactionsRepository,
          RecurringTransactionsRepository,
          RecurringTransactionsRepository
        >
    with $Provider<RecurringTransactionsRepository> {
  RecurringTransactionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecurringTransactionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringTransactionsRepository create(Ref ref) {
    return recurringTransactionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringTransactionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringTransactionsRepository>(
        value,
      ),
    );
  }
}

String _$recurringTransactionsRepositoryHash() =>
    r'3609f9cdd9d31234036bd18101d8aedb6e1800d3';
