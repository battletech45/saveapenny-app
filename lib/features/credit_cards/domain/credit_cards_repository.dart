import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_statement.dart';

class CreditCardStatementPage {
  const CreditCardStatementPage({
    required this.items,
    required this.page,
    required this.hasNext,
  });

  final List<CreditCardStatement> items;
  final int page;
  final bool hasNext;
}

abstract interface class CreditCardsRepository {
  Future<CreditCardSummary> updateDetails({
    required String accountId,
    required num creditLimit,
    required num apr,
    required int statementDay,
  });

  Future<CreditCardStatementPage> listStatements({
    required String accountId,
    int page = 0,
    int size = 20,
  });

  Future<CreditCardPaymentResult> makePayment({
    required String accountId,
    required String sourceAccountId,
    required CreditCardPaymentType paymentType,
    num? amount,
  });
}
