import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';
import 'package:saveapenny/features/credit_cards/data/credit_cards_repository.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_statement.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_cards_repository.dart';
import 'package:saveapenny/features/credit_cards/presentation/credit_card_detail_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({required this.accounts});

  final List<Account> accounts;

  @override
  Future<List<Account>> list() async => accounts;

  @override
  Future<DateTime?> lastSyncedAt() async => null;

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(String accountId) => throw UnimplementedError();

  @override
  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) => throw UnimplementedError();
}

class _FakeCreditCardsRepository implements CreditCardsRepository {
  @override
  Future<CreditCardStatementPage> listStatements({
    required String accountId,
    int page = 0,
    int size = 20,
  }) async {
    return const CreditCardStatementPage(
      items: <CreditCardStatement>[],
      page: 0,
      hasNext: false,
    );
  }

  @override
  Future<CreditCardPaymentResult> makePayment({
    required String accountId,
    required String sourceAccountId,
    required CreditCardPaymentType paymentType,
    num? amount,
  }) => throw UnimplementedError();

  @override
  Future<CreditCardSummary> updateDetails({
    required String accountId,
    required num creditLimit,
    required num apr,
    required int statementDay,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets(
    'renders an inline empty state with no statements without crashing on layout',
    (WidgetTester tester) async {
      final account = Account(
        id: 'acc-1',
        name: 'Card',
        type: AccountType.credit,
        currency: 'TRY',
        balance: 0,
        initialBalance: 0,
        active: true,
        createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
        updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
        creditCard: const CreditCardSummary(
          creditLimit: 5000,
          apr: 24.99,
          statementDay: 15,
          gracePeriodDays: 21,
          availableCredit: 5000,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(accounts: <Account>[account]),
          ),
          creditCardsRepositoryProvider.overrideWith(
            (ref) => _FakeCreditCardsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const CreditCardDetailScreen(accountId: 'acc-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.creditCardStatementsEmptyTitle), findsOneWidget);
    },
  );
}
