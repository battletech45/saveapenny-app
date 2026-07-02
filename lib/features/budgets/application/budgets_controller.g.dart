// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetsController)
final budgetsControllerProvider = BudgetsControllerProvider._();

final class BudgetsControllerProvider
    extends $AsyncNotifierProvider<BudgetsController, BudgetsState> {
  BudgetsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetsControllerHash();

  @$internal
  @override
  BudgetsController create() => BudgetsController();
}

String _$budgetsControllerHash() => r'245e3a1fc23479976d0cfd36e987f49a33ed292b';

abstract class _$BudgetsController extends $AsyncNotifier<BudgetsState> {
  FutureOr<BudgetsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BudgetsState>, BudgetsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BudgetsState>, BudgetsState>,
              AsyncValue<BudgetsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
