import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_access.freezed.dart';

@freezed
abstract class FeatureAccess with _$FeatureAccess {
  const factory FeatureAccess({
    required bool assistant,
    required bool insights,
    required bool stocks,
    required bool ocr,
    required bool csvImport,
    required bool reportExport,
    required bool advancedRecurring,
    required bool goalWhatIf,
  }) = _FeatureAccess;

  static const FeatureAccess locked = FeatureAccess(
    assistant: false,
    insights: false,
    stocks: false,
    ocr: false,
    csvImport: false,
    reportExport: false,
    advancedRecurring: false,
    goalWhatIf: false,
  );
}

@freezed
abstract class PlanLimits with _$PlanLimits {
  const factory PlanLimits({
    required int activeBudgets,
    int? maxActiveBudgets,
    required int activeGoals,
    int? maxActiveGoals,
    required int reportHistoryMonths,
  }) = _PlanLimits;
}
