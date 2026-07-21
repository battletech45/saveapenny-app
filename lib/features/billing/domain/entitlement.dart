import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/features/billing/domain/plan.dart';

part 'entitlement.freezed.dart';

@freezed
abstract class Entitlement with _$Entitlement {
  const factory Entitlement({
    required Plan plan,
    required EntitlementStatus status,
    required bool isActive,
    required bool willRenew,
    DateTime? expiresAt,
    DateTime? trialEndsAt,
    required FeatureAccess features,
    required PlanLimits limits,
  }) = _Entitlement;
}
