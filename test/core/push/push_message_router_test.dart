import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/push/push_message_router.dart';

void main() {
  test('routes a goal-off-track push to the goal detail screen', () {
    expect(
      resolvePushRoute(<String, Object?>{
        'type': 'GOAL_OFF_TRACK',
        'goalId': 'g-1',
      }),
      '/goals/g-1',
    );
  });

  test('falls back to the goals list when goalId is missing', () {
    expect(
      resolvePushRoute(<String, Object?>{'type': 'GOAL_OFF_TRACK'}),
      '/goals',
    );
  });

  test('routes an insight-generated push to the insight detail screen', () {
    expect(
      resolvePushRoute(<String, Object?>{
        'type': 'INSIGHT_GENERATED',
        'insightId': 'i-1',
      }),
      '/insights/i-1',
    );
  });

  test('routes budget warning and exceeded pushes to the budgets list', () {
    expect(
      resolvePushRoute(<String, Object?>{'type': 'BUDGET_WARNING'}),
      '/budgets',
    );
    expect(
      resolvePushRoute(<String, Object?>{'type': 'BUDGET_EXCEEDED'}),
      '/budgets',
    );
  });

  test('routes a recurring-transaction-created push to that screen', () {
    expect(
      resolvePushRoute(<String, Object?>{
        'type': 'RECURRING_TRANSACTION_CREATED',
      }),
      '/recurring-transactions',
    );
  });

  test('is case-insensitive on the type field', () {
    expect(
      resolvePushRoute(<String, Object?>{'type': 'budget_warning'}),
      '/budgets',
    );
  });

  test('falls back to the notifications list for an unknown type', () {
    expect(
      resolvePushRoute(<String, Object?>{'type': 'SOMETHING_NEW'}),
      '/notifications',
    );
  });

  test('falls back to the notifications list when type is missing', () {
    expect(resolvePushRoute(<String, Object?>{}), '/notifications');
  });
}
