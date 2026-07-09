import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/goals/data/goals_repository.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_detail.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';
import 'package:saveapenny/features/goals/domain/goal_scenario.dart';
import 'package:saveapenny/features/goals/domain/goals_repository.dart';
import 'package:saveapenny/features/goals/presentation/goal_detail_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeGoalsRepository implements GoalsRepository {
  _FakeGoalsRepository({
    required this.detail,
    this.onUpdateStatus,
  });

  final GoalDetail detail;
  final Future<Goal> Function({required String goalId, required GoalStatus status})?
  onUpdateStatus;

  @override
  Future<Goal> create({
    required GoalType type,
    required String title,
    required num targetAmount,
    required String currency,
    required DateTime targetDate,
    String? linkedAccountId,
    required Map<String, dynamic> inputs,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<GoalScenario> createScenario({
    required String goalId,
    required String name,
    required Map<String, dynamic> inputs,
    bool? isBaseline,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String goalId) {
    throw UnimplementedError();
  }

  @override
  Future<GoalDetail> getById(String goalId) async => detail;

  @override
  Future<List<GoalScenario>> listScenarios(String goalId) async => detail.scenarios;

  @override
  Future<PaginatedData<Goal>> list({
    GoalStatus? status,
    GoalType? type,
    int page = 0,
    int size = 20,
  }) async {
    return PaginatedData<Goal>(
      items: const <Goal>[],
      page: page,
      size: size,
      totalItems: 0,
      totalPages: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<PaginatedData<GoalRun>> listRuns(
    String goalId, {
    int page = 0,
    int size = 20,
  }) async {
    return PaginatedData<GoalRun>(
      items: const <GoalRun>[],
      page: page,
      size: size,
      totalItems: 0,
      totalPages: 1,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<Goal> update({
    required String goalId,
    String? title,
    num? targetAmount,
    String? currency,
    DateTime? targetDate,
    String? linkedAccountId,
    Map<String, dynamic>? inputs,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Goal> updateStatus({
    required String goalId,
    required GoalStatus status,
  }) async {
    if (onUpdateStatus != null) {
      return onUpdateStatus!(goalId: goalId, status: status);
    }

    return Goal(
      id: detail.id,
      type: detail.type,
      title: detail.title,
      targetAmount: detail.targetAmount,
      currency: detail.currency,
      targetDate: detail.targetDate,
      linkedAccountId: detail.linkedAccountId,
      status: status,
      inputs: detail.inputs,
      createdAt: detail.createdAt,
      updatedAt: detail.updatedAt,
    );
  }
}

GoalDetail _goalDetail({GoalStatus status = GoalStatus.active}) {
  return GoalDetail(
    id: 'goal-1',
    type: GoalType.savings,
    title: 'Emergency fund',
    targetAmount: 10000,
    currency: 'TRY',
    targetDate: DateTime.parse('2027-01-01T00:00:00Z'),
    linkedAccountId: 'account-1',
    status: status,
    inputs: const <String, dynamic>{'monthlyContribution': 1000},
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
    scenarios: const <GoalScenario>[],
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const GoalDetailScreen(goalId: 'goal-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('goal detail shows localized status failure message', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        goalsRepositoryProvider.overrideWith(
          (ref) => _FakeGoalsRepository(
            detail: _goalDetail(),
            onUpdateStatus: ({required goalId, required status}) async {
              throw const Failure.api(
                code: ApiErrorCode.invalidGoalStatusTransition,
                message: 'Invalid goal status transition.',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpScreen(tester, container: container);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Change status'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Draft').last);
    await tester.pumpAndSettle();

    expect(
      find.text('That status transition is not allowed for this goal.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
