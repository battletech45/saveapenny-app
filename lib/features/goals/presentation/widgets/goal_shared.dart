import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/ui/charts.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String goalStatusLabel(AppLocalizations l10n, GoalStatus status) {
  return switch (status) {
    GoalStatus.draft => l10n.goalsStatusDraft,
    GoalStatus.active => l10n.goalsStatusActive,
    GoalStatus.achieved => l10n.goalsStatusAchieved,
    GoalStatus.abandoned => l10n.goalsStatusAbandoned,
  };
}

String goalTypeLabel(AppLocalizations l10n, GoalType type) {
  return switch (type) {
    GoalType.savings => l10n.goalsTypeSavings,
    GoalType.debtPayoff => l10n.goalsTypeDebtPayoff,
    GoalType.purchase => l10n.goalsTypePurchase,
    GoalType.retirement => l10n.goalsTypeRetirement,
    GoalType.incomeTarget => l10n.goalsTypeIncomeTarget,
  };
}

IconData goalTypeIcon(GoalType type) {
  return switch (type) {
    GoalType.savings => Icons.savings_outlined,
    GoalType.debtPayoff => Icons.credit_score_outlined,
    GoalType.purchase => Icons.shopping_bag_outlined,
    GoalType.retirement => Icons.beach_access_outlined,
    GoalType.incomeTarget => Icons.trending_up_rounded,
  };
}

String goalFeasibilityLabel(AppLocalizations l10n, GoalFeasibility value) {
  return switch (value) {
    GoalFeasibility.onTrack => l10n.goalsFeasibilityOnTrack,
    GoalFeasibility.tight => l10n.goalsFeasibilityTight,
    GoalFeasibility.atRisk => l10n.goalsFeasibilityAtRisk,
    GoalFeasibility.infeasible => l10n.goalsFeasibilityInfeasible,
  };
}

String goalRunTriggerLabel(AppLocalizations l10n, GoalRunTrigger value) {
  return switch (value) {
    GoalRunTrigger.user => l10n.goalsRunTriggerUser,
    GoalRunTrigger.agent => l10n.goalsRunTriggerAgent,
    GoalRunTrigger.progressJob => l10n.goalsRunTriggerProgressJob,
    GoalRunTrigger.whatIf => l10n.goalsRunTriggerWhatIf,
  };
}

String goalFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure(message: final message) =>
      message != null && message.isNotEmpty
          ? message
          : l10n.failureGenericMessage,
    ApiFailure(
      code: final code,
      message: final message,
      details: final details,
    ) =>
      switch (code) {
        ApiErrorCode.invalidGoalDate => l10n.goalsInvalidDateError,
        ApiErrorCode.invalidGoalStatusTransition =>
          l10n.goalsInvalidStatusTransitionError,
        ApiErrorCode.invalidGoalType => l10n.goalsInvalidTypeError,
        ApiErrorCode.goalNotFound ||
        ApiErrorCode.linkedAccountNotFound ||
        ApiErrorCode.scenarioNotFound => l10n.failureResourceNotFoundMessage,
        ApiErrorCode.validationFailed =>
          details.isNotEmpty
              ? details.first
              : l10n.failureValidationFailedMessage,
        ApiErrorCode.goalProgressDisabled ||
        ApiErrorCode.featureDisabled => l10n.failureFeatureDisabledMessage,
        ApiErrorCode.serverError ||
        ApiErrorCode.internalServerError ||
        ApiErrorCode.serviceUnavailable => l10n.failureGenericMessage,
        _ => message.isNotEmpty ? message : l10n.failureValidationFailedMessage,
      },
  };
}

const List<String> _seriesValueKeys = <String>[
  'value',
  'amount',
  'balance',
  'projectedBalance',
  'y',
];

/// Best-effort parse of `GoalRun.outputSeries` — an untyped `Object?` with no
/// documented shape — into chart points. Only returns points when the shape
/// is unambiguous (a flat numeric list, or a list of maps each carrying
/// exactly one recognizable numeric field); returns null otherwise so the
/// caller can fall back to the raw JSON view rather than rendering a chart
/// built on a guess.
List<TrendPoint>? tryParseGoalSeries(Object? value) {
  if (value is! List || value.length < 2) {
    return null;
  }

  if (value.every((element) => element is num)) {
    return <TrendPoint>[
      for (var i = 0; i < value.length; i++)
        TrendPoint(i.toDouble(), (value[i] as num).toDouble()),
    ];
  }

  if (value.every((element) => element is Map)) {
    final points = <TrendPoint>[];
    for (var i = 0; i < value.length; i++) {
      final map = (value[i] as Map).cast<String, dynamic>();
      final key = _seriesValueKeys.firstWhere(
        (candidate) => map[candidate] is num,
        orElse: () => '',
      );
      if (key.isEmpty) {
        return null;
      }
      points.add(TrendPoint(i.toDouble(), (map[key] as num).toDouble()));
    }
    return points;
  }

  return null;
}

String prettyGoalJson(Object? value) {
  if (value == null) {
    return '';
  }

  if (value is! Map<String, dynamic> && value is! List<Object?>) {
    return value.toString();
  }

  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(value);
}

String formatGoalDate(BuildContext context, DateTime value) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String formatGoalDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final date = DateFormat.yMMMd(locale).format(value);
  final time = DateFormat.Hm(locale).format(value);
  return '$date $time';
}

Color goalStatusColor(BuildContext context, GoalStatus status) {
  return switch (status) {
    GoalStatus.draft => context.colors.textSecondary,
    GoalStatus.active => Theme.of(context).colorScheme.primary,
    GoalStatus.achieved => context.finance.income,
    GoalStatus.abandoned => context.finance.expense,
  };
}

DateTime goalToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

T? readAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
