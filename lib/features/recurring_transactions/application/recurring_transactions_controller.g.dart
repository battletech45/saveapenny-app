// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transactions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecurringTransactionsController)
final recurringTransactionsControllerProvider =
    RecurringTransactionsControllerProvider._();

final class RecurringTransactionsControllerProvider
    extends
        $AsyncNotifierProvider<
          RecurringTransactionsController,
          RecurringTransactionsState
        > {
  RecurringTransactionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionsControllerHash();

  @$internal
  @override
  RecurringTransactionsController create() => RecurringTransactionsController();
}

String _$recurringTransactionsControllerHash() =>
    r'e6d22132498c78c3ffc9a2cf2cb56884519527d0';

abstract class _$RecurringTransactionsController
    extends $AsyncNotifier<RecurringTransactionsState> {
  FutureOr<RecurringTransactionsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<RecurringTransactionsState>,
              RecurringTransactionsState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RecurringTransactionsState>,
                RecurringTransactionsState
              >,
              AsyncValue<RecurringTransactionsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(RecurringTransactionHistoryController)
final recurringTransactionHistoryControllerProvider =
    RecurringTransactionHistoryControllerFamily._();

final class RecurringTransactionHistoryControllerProvider
    extends
        $AsyncNotifierProvider<
          RecurringTransactionHistoryController,
          RecurringTransactionHistoryState
        > {
  RecurringTransactionHistoryControllerProvider._({
    required RecurringTransactionHistoryControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recurringTransactionHistoryControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$recurringTransactionHistoryControllerHash();

  @override
  String toString() {
    return r'recurringTransactionHistoryControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecurringTransactionHistoryController create() =>
      RecurringTransactionHistoryController();

  @override
  bool operator ==(Object other) {
    return other is RecurringTransactionHistoryControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringTransactionHistoryControllerHash() =>
    r'3f542b89a73a50c50a6c133413d73b9137671bbf';

final class RecurringTransactionHistoryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RecurringTransactionHistoryController,
          AsyncValue<RecurringTransactionHistoryState>,
          RecurringTransactionHistoryState,
          FutureOr<RecurringTransactionHistoryState>,
          String
        > {
  RecurringTransactionHistoryControllerFamily._()
    : super(
        retry: null,
        name: r'recurringTransactionHistoryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RecurringTransactionHistoryControllerProvider call(
    String recurringTransactionId,
  ) => RecurringTransactionHistoryControllerProvider._(
    argument: recurringTransactionId,
    from: this,
  );

  @override
  String toString() => r'recurringTransactionHistoryControllerProvider';
}

abstract class _$RecurringTransactionHistoryController
    extends $AsyncNotifier<RecurringTransactionHistoryState> {
  late final _$args = ref.$arg as String;
  String get recurringTransactionId => _$args;

  FutureOr<RecurringTransactionHistoryState> build(
    String recurringTransactionId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<RecurringTransactionHistoryState>,
              RecurringTransactionHistoryState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RecurringTransactionHistoryState>,
                RecurringTransactionHistoryState
              >,
              AsyncValue<RecurringTransactionHistoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
