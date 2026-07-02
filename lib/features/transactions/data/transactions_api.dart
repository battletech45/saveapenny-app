import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/transactions/data/dto/create_transaction_request.dart';
import 'package:saveapenny/features/transactions/data/dto/create_transfer_request.dart';
import 'package:saveapenny/features/transactions/data/dto/transaction_response.dart';
import 'package:saveapenny/features/transactions/data/dto/transfer_response.dart';
import 'package:saveapenny/features/transactions/data/dto/update_transaction_request.dart';

part 'transactions_api.g.dart';

class TransactionsApi {
  TransactionsApi(this._apiClient) : _dateFormat = DateFormat('yyyy-MM-dd');

  final ApiClient _apiClient;
  final DateFormat _dateFormat;

  Future<PaginatedData<TransactionResponse>> list({
    DateTime? from,
    DateTime? to,
    String? type,
    String? accountId,
    String? categoryId,
    num? minAmount,
    num? maxAmount,
    String? keyword,
    int page = 0,
    int size = 20,
    String sort = 'transactionDate,desc',
  }) {
    return _apiClient.send<PaginatedData<TransactionResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/transactions',
        queryParameters: <String, Object?>{
          'from': from == null ? null : _dateFormat.format(from),
          'to': to == null ? null : _dateFormat.format(to),
          'type': type,
          'accountId': accountId,
          'categoryId': categoryId,
          'minAmount': minAmount,
          'maxAmount': maxAmount,
          'keyword': keyword,
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) => PaginatedData<TransactionResponse>.fromJson(
        _readJsonMap(data),
        (item) => TransactionResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<TransactionResponse> create(CreateTransactionRequest request) {
    return _apiClient.send<TransactionResponse>(
      call: (dio) => dio.post<dynamic>('/transactions', data: request.toJson()),
      fromData: (data) => TransactionResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<TransferResponse> createTransfer(CreateTransferRequest request) {
    return _apiClient.send<TransferResponse>(
      call: (dio) =>
          dio.post<dynamic>('/transactions/transfer', data: request.toJson()),
      fromData: (data) => TransferResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<TransactionResponse> update({
    required String transactionId,
    required UpdateTransactionRequest request,
  }) {
    return _apiClient.send<TransactionResponse>(
      call: (dio) => dio.put<dynamic>(
        '/transactions/$transactionId',
        data: request.toJson(),
      ),
      fromData: (data) => TransactionResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> delete(String transactionId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>('/transactions/$transactionId'),
      fromData: (_) {},
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
TransactionsApi transactionsApi(Ref ref) {
  return TransactionsApi(ref.watch(apiClientProvider));
}
