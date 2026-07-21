import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/billing/domain/entitlement.dart';
import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';

part 'entitlement_response.freezed.dart';
part 'entitlement_response.g.dart';

@freezed
abstract class EntitlementResponse with _$EntitlementResponse {
  const factory EntitlementResponse({
    required String plan,
    required String status,
    required bool isActive,
    required bool willRenew,
    DateTime? expiresAt,
    DateTime? trialEndsAt,
    required FeatureFlagsDto features,
    required PlanLimitsDto limits,
  }) = _EntitlementResponse;

  factory EntitlementResponse.fromJson(Map<String, dynamic> json) =>
      _$EntitlementResponseFromJson(json);
}

@freezed
abstract class FeatureFlagsDto with _$FeatureFlagsDto {
  const factory FeatureFlagsDto({
    required bool assistant,
    required bool insights,
    required bool stocks,
    required bool ocr,
    required bool csvImport,
    required bool reportExport,
    required bool advancedRecurring,
    required bool goalWhatIf,
  }) = _FeatureFlagsDto;

  factory FeatureFlagsDto.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagsDtoFromJson(json);
}

@freezed
abstract class PlanLimitsDto with _$PlanLimitsDto {
  const factory PlanLimitsDto({
    required int activeBudgets,
    int? maxActiveBudgets,
    required int activeGoals,
    int? maxActiveGoals,
    required int reportHistoryMonths,
  }) = _PlanLimitsDto;

  factory PlanLimitsDto.fromJson(Map<String, dynamic> json) =>
      _$PlanLimitsDtoFromJson(json);
}

extension EntitlementResponseMapper on EntitlementResponse {
  Entitlement toDomain() {
    return Entitlement(
      plan: Plan.fromWire(plan),
      status: EntitlementStatus.fromWire(status),
      isActive: isActive,
      willRenew: willRenew,
      expiresAt: expiresAt,
      trialEndsAt: trialEndsAt,
      features: FeatureAccess(
        assistant: features.assistant,
        insights: features.insights,
        stocks: features.stocks,
        ocr: features.ocr,
        csvImport: features.csvImport,
        reportExport: features.reportExport,
        advancedRecurring: features.advancedRecurring,
        goalWhatIf: features.goalWhatIf,
      ),
      limits: PlanLimits(
        activeBudgets: limits.activeBudgets,
        maxActiveBudgets: limits.maxActiveBudgets,
        activeGoals: limits.activeGoals,
        maxActiveGoals: limits.maxActiveGoals,
        reportHistoryMonths: limits.reportHistoryMonths,
      ),
    );
  }
}
