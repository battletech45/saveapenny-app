import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/accounts/data/dto/account_response.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/credit_cards/data/credit_cards_api.dart';
import 'package:saveapenny/features/credit_cards/data/dto/credit_card_details_request.dart';
import 'package:saveapenny/features/credit_cards/data/dto/credit_card_payment_request.dart';
import 'package:saveapenny/features/credit_cards/data/dto/credit_card_payment_response.dart';
import 'package:saveapenny/features/credit_cards/data/dto/credit_card_statement_response.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_cards_repository.dart';

part 'credit_cards_repository.g.dart';

class CreditCardsRepositoryImpl implements CreditCardsRepository {
  const CreditCardsRepositoryImpl(this._creditCardsApi);

  final CreditCardsApi _creditCardsApi;

  @override
  Future<CreditCardSummary> updateDetails({
    required String accountId,
    required num creditLimit,
    required num apr,
    required int statementDay,
  }) async {
    final response = await _creditCardsApi.updateDetails(
      accountId: accountId,
      request: CreditCardDetailsRequest(
        creditLimit: creditLimit,
        apr: apr,
        statementDay: statementDay,
      ),
    );

    return response.toDomain();
  }

  @override
  Future<CreditCardStatementPage> listStatements({
    required String accountId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _creditCardsApi.listStatements(
      accountId: accountId,
      page: page,
      size: size,
    );

    return CreditCardStatementPage(
      items: response.items
          .map((CreditCardStatementResponse item) => item.toDomain())
          .toList(growable: false),
      page: response.page,
      hasNext: response.hasNext,
    );
  }

  @override
  Future<CreditCardPaymentResult> makePayment({
    required String accountId,
    required String sourceAccountId,
    required CreditCardPaymentType paymentType,
    num? amount,
  }) async {
    final response = await _creditCardsApi.makePayment(
      accountId: accountId,
      request: CreditCardPaymentRequest(
        sourceAccountId: sourceAccountId,
        paymentType: creditCardPaymentTypeToWire(paymentType),
        amount: amount,
      ),
    );

    return response.toDomain();
  }
}

@Riverpod(keepAlive: true)
CreditCardsRepository creditCardsRepository(Ref ref) {
  return CreditCardsRepositoryImpl(ref.watch(creditCardsApiProvider));
}
