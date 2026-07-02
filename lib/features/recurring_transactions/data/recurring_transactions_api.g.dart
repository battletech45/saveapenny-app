// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transactions_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringTransactionsApi)
final recurringTransactionsApiProvider = RecurringTransactionsApiProvider._();

final class RecurringTransactionsApiProvider
    extends
        $FunctionalProvider<
          RecurringTransactionsApi,
          RecurringTransactionsApi,
          RecurringTransactionsApi
        >
    with $Provider<RecurringTransactionsApi> {
  RecurringTransactionsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionsApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionsApiHash();

  @$internal
  @override
  $ProviderElement<RecurringTransactionsApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringTransactionsApi create(Ref ref) {
    return recurringTransactionsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringTransactionsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringTransactionsApi>(value),
    );
  }
}

String _$recurringTransactionsApiHash() =>
    r'010bd0f5a471653e7994a8da91b1559c2216674c';
