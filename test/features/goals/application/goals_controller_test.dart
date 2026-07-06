import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/goals/application/goals_controller.dart';
import 'package:saveapenny/features/goals/data/goals_repository.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_detail.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';
import 'package:saveapenny/features/goals/domain/goal_scenario.dart';
import 'package:saveapenny/features/goals/domain/goals_repository.dart';

class _FakeGoalsRepository implements GoalsRepository {
  _FakeGoalsRepository({this.onList, this.onCreate});

  final Future<PaginatedData<Goal>> Function()? onList;
  final Future<Goal> Function({
    required GoalType type,
    required String title,
    required num targetAmount,
    required String currency,
    required DateTime targetDate,
    String? linkedAccountId,
    required Map<String, dynamic> inputs,
  })?
  onCreate;

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
    return onCreate!(
      type: type,
      title: title,
      targetAmount: targetAmount,
      currency: currency,
      targetDate: targetDate,
      linkedAccountId: linkedAccountId,
      inputs: inputs,
    );
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
  Future<GoalDetail> getById(String goalId) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedData<Goal>> list({
    GoalStatus? status,
    GoalType? type,
    int page = 0,
    int size = 20,
  }) {
    return onList!();
  }

  @override
  Future<PaginatedData<GoalRun>> listRuns(
    String goalId, {
    int page = 0,
    int size = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<GoalScenario>> listScenarios(String goalId) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }
}

Goal _goal({required String id}) {
  return Goal(
    id: id,
    type: GoalType.savings,
    title: 'Emergency fund',
    targetAmount: 10000,
    currency: 'USD',
    targetDate: DateTime.parse('2027-12-31T00:00:00Z'),
    linkedAccountId: null,
    status: GoalStatus.active,
    inputs: const <String, dynamic>{'monthlyContribution': 350},
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

PaginatedData<Goal> _page(
  List<Goal> items, {
  int page = 0,
  bool hasNext = false,
  bool hasPrevious = false,
}) {
  return PaginatedData<Goal>(
    items: items,
    page: page,
    size: 20,
    totalItems: items.length,
    totalPages: hasNext ? page + 2 : page + 1,
    hasNext: hasNext,
    hasPrevious: hasPrevious,
  );
}

void main() {
  test('build loads the first goals page', () async {
    final existing = _goal(id: 'g-1');

    final container = ProviderContainer(
      overrides: [
        goalsRepositoryProvider.overrideWith(
          (ref) =>
              _FakeGoalsRepository(onList: () async => _page(<Goal>[existing])),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(goalsControllerProvider.future);

    expect(state.items, hasLength(1));
    expect(state.items.single, existing);
  });

  test('create preserves current list when the mutation fails', () async {
    final existing = _goal(id: 'g-1');

    final container = ProviderContainer(
      overrides: [
        goalsRepositoryProvider.overrideWith(
          (ref) => _FakeGoalsRepository(
            onList: () async => _page(<Goal>[existing]),
            onCreate:
                ({
                  required type,
                  required title,
                  required targetAmount,
                  required currency,
                  required targetDate,
                  linkedAccountId,
                  required inputs,
                }) => Future<Goal>.error(
                  const Failure.api(
                    code: ApiErrorCode.invalidGoalDate,
                    message: 'Invalid goal date.',
                  ),
                ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(goalsControllerProvider.future);

    await expectLater(
      container
          .read(goalsControllerProvider.notifier)
          .create(
            type: GoalType.savings,
            title: 'Emergency fund',
            targetAmount: 10000,
            currency: 'USD',
            targetDate: DateTime.parse('2027-12-31T00:00:00Z'),
            linkedAccountId: null,
            inputs: const <String, dynamic>{'monthlyContribution': 350},
          ),
      throwsA(isA<ApiFailure>()),
    );

    expect(
      container.read(goalsControllerProvider).value?.items.single,
      existing,
    );
  });
}
