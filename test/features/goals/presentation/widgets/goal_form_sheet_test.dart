import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/ui/app_dropdown_field.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({required this.accounts});

  final List<Account> accounts;

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String accountId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> list() async => accounts;

  @override
  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) {
    throw UnimplementedError();
  }
}

Account _account({
  required String id,
  required String name,
  bool active = true,
}) {
  return Account(
    id: id,
    name: name,
    type: AccountType.bank,
    currency: 'TRY',
    balance: 1000,
    initialBalance: 1000,
    active: active,
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2026-01-01T00:00:00Z'),
  );
}

Goal _goal({String? linkedAccountId}) {
  return Goal(
    id: 'goal-1',
    type: GoalType.savings,
    title: 'Emergency fund',
    targetAmount: 10000,
    currency: 'TRY',
    targetDate: DateTime.parse('2027-01-01T00:00:00Z'),
    linkedAccountId: linkedAccountId,
    status: GoalStatus.draft,
    inputs: const <String, dynamic>{'monthlyContribution': 1000},
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
  );
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required ProviderContainer container,
  required Goal goal,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GoalFormSheet(existing: goal, goalId: goal.id),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('goal form deduplicates linked account dropdown items', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(
            accounts: <Account>[
              _account(id: 'account-1', name: 'Main bank'),
              _account(id: 'account-1', name: 'Shadow bank'),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpSheet(
      tester,
      container: container,
      goal: _goal(linkedAccountId: 'account-1'),
    );

    await tester.tap(find.byType(AppDropdownField<String?>).first);
    await tester.pumpAndSettle();

    expect(find.text('Main bank'), findsWidgets);
    expect(find.text('Shadow bank'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'goal form keeps missing linked account selectable in edit mode',
    (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(
              accounts: <Account>[
                _account(id: 'account-2', name: 'Travel fund'),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpSheet(
        tester,
        container: container,
        goal: _goal(linkedAccountId: 'missing-account'),
      );

      expect(find.text('missing-account'), findsOneWidget);

      await tester.tap(find.byType(AppDropdownField<String?>).first);
      await tester.pumpAndSettle();

      expect(find.text('missing-account'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
