import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/dashboard/presentation/widgets/account_row.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

Account _account({required AccountType type, required num balance}) {
  return Account(
    id: 'a-1',
    name: 'Test account',
    type: type,
    currency: 'TRY',
    balance: balance,
    initialBalance: 0,
    active: true,
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

Future<void> _pumpRow(WidgetTester tester, Account account) async {
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (context, state) =>
                Scaffold(body: AccountRow(account: account)),
          ),
          GoRoute(
            path: '/accounts',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders a CREDIT balance as debt (minus sign)', (
    WidgetTester tester,
  ) async {
    await _pumpRow(tester, _account(type: AccountType.credit, balance: 500));

    expect(find.textContaining('-'), findsOneWidget);
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('renders a non-CREDIT balance as funds on hand (plus sign)', (
    WidgetTester tester,
  ) async {
    await _pumpRow(tester, _account(type: AccountType.bank, balance: 500));

    expect(find.textContaining('+'), findsOneWidget);
    expect(find.textContaining('-'), findsNothing);
  });
}
