// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetsApi)
final budgetsApiProvider = BudgetsApiProvider._();

final class BudgetsApiProvider
    extends $FunctionalProvider<BudgetsApi, BudgetsApi, BudgetsApi>
    with $Provider<BudgetsApi> {
  BudgetsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetsApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetsApiHash();

  @$internal
  @override
  $ProviderElement<BudgetsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetsApi create(Ref ref) {
    return budgetsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetsApi>(value),
    );
  }
}

String _$budgetsApiHash() => r'a658d3ccd4fcbe28850918df8b8848675185361c';
