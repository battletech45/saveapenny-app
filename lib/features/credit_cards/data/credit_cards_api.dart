import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/accounts/data/dto/account_response.dart';
import 'package:saveapenny/features/credit_cards/data/dto/credit_card_details_request.dart';
import 'package:saveapenny/features/credit_cards/data/dto/credit_card_payment_request.dart';
import 'package:saveapenny/features/credit_cards/data/dto/credit_card_payment_response.dart';
import 'package:saveapenny/features/credit_cards/data/dto/credit_card_statement_response.dart';

part 'credit_cards_api.g.dart';

class CreditCardsApi {
  const CreditCardsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<CreditCardSummaryResponse> updateDetails({
    required String accountId,
    required CreditCardDetailsRequest request,
  }) {
    return _apiClient.send<CreditCardSummaryResponse>(
      call: (dio) => dio.patch<dynamic>(
        '/accounts/$accountId/credit',
        data: request.toJson(),
      ),
      fromData: (data) =>
          CreditCardSummaryResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<PaginatedData<CreditCardStatementResponse>> listStatements({
    required String accountId,
    int page = 0,
    int size = 20,
  }) {
    return _apiClient.send<PaginatedData<CreditCardStatementResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/accounts/$accountId/credit/statements',
        queryParameters: <String, Object?>{'page': page, 'size': size},
      ),
      fromData: (data) => PaginatedData<CreditCardStatementResponse>.fromJson(
        _readJsonMap(data),
        (item) => CreditCardStatementResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<CreditCardPaymentResponse> makePayment({
    required String accountId,
    required CreditCardPaymentRequest request,
  }) {
    return _apiClient.send<CreditCardPaymentResponse>(
      call: (dio) => dio.post<dynamic>(
        '/accounts/$accountId/credit/payments',
        data: request.toJson(),
      ),
      fromData: (data) =>
          CreditCardPaymentResponse.fromJson(_readJsonMap(data)),
    );
  }
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
CreditCardsApi creditCardsApi(Ref ref) {
  return CreditCardsApi(ref.watch(apiClientProvider));
}
