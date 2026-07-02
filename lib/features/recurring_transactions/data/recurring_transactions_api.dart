import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/create_recurring_transaction_request.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/recurring_transaction_history_entry_response.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/recurring_transaction_response.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/upcoming_recurring_transaction_response.dart';
import 'package:saveapenny/features/recurring_transactions/data/dto/update_recurring_transaction_request.dart';

part 'recurring_transactions_api.g.dart';

class RecurringTransactionsApi {
  RecurringTransactionsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedData<RecurringTransactionResponse>> list({
    int page = 0,
    int size = 20,
    String sort = 'nextRunDate,asc',
  }) {
    return _apiClient.send<PaginatedData<RecurringTransactionResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/automations/recurring-transactions',
        queryParameters: <String, Object?>{
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) => PaginatedData<RecurringTransactionResponse>.fromJson(
        _readJsonMap(data),
        (item) => RecurringTransactionResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<RecurringTransactionResponse> get(String recurringTransactionId) {
    return _apiClient.send<RecurringTransactionResponse>(
      call: (dio) => dio.get<dynamic>(
        '/automations/recurring-transactions/$recurringTransactionId',
      ),
      fromData: (data) =>
          RecurringTransactionResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<RecurringTransactionResponse> create(
    CreateRecurringTransactionRequest request,
  ) {
    return _apiClient.send<RecurringTransactionResponse>(
      call: (dio) => dio.post<dynamic>(
        '/automations/recurring-transactions',
        data: request.toJson(),
      ),
      fromData: (data) =>
          RecurringTransactionResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<RecurringTransactionResponse> update({
    required String recurringTransactionId,
    required UpdateRecurringTransactionRequest request,
  }) {
    return _apiClient.send<RecurringTransactionResponse>(
      call: (dio) => dio.put<dynamic>(
        '/automations/recurring-transactions/$recurringTransactionId',
        data: request.toJson(),
      ),
      fromData: (data) =>
          RecurringTransactionResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> delete(String recurringTransactionId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>(
        '/automations/recurring-transactions/$recurringTransactionId',
      ),
      fromData: (_) {},
    );
  }

  Future<RecurringTransactionResponse> pause(String recurringTransactionId) {
    return _apiClient.send<RecurringTransactionResponse>(
      call: (dio) => dio.patch<dynamic>(
        '/automations/recurring-transactions/$recurringTransactionId/pause',
      ),
      fromData: (data) =>
          RecurringTransactionResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<RecurringTransactionResponse> resume(String recurringTransactionId) {
    return _apiClient.send<RecurringTransactionResponse>(
      call: (dio) => dio.patch<dynamic>(
        '/automations/recurring-transactions/$recurringTransactionId/resume',
      ),
      fromData: (data) =>
          RecurringTransactionResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<PaginatedData<RecurringTransactionHistoryEntryResponse>> history(
    String recurringTransactionId, {
    int page = 0,
    int size = 20,
    String sort = 'scheduledDate,desc',
  }) {
    return _apiClient.send<
      PaginatedData<RecurringTransactionHistoryEntryResponse>
    >(
      call: (dio) => dio.get<dynamic>(
        '/automations/recurring-transactions/$recurringTransactionId/history',
        queryParameters: <String, Object?>{
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) =>
          PaginatedData<RecurringTransactionHistoryEntryResponse>.fromJson(
            _readJsonMap(data),
            (item) => RecurringTransactionHistoryEntryResponse.fromJson(
              _readJsonMap(item),
            ),
          ),
    );
  }

  Future<List<UpcomingRecurringTransactionResponse>> upcoming({
    int limit = 10,
  }) {
    return _apiClient.send<List<UpcomingRecurringTransactionResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/automations/recurring-transactions/upcoming',
        queryParameters: <String, Object?>{'limit': limit},
      ),
      fromData: (data) {
        if (data is List<Object?>) {
          return data
              .map(
                (item) => UpcomingRecurringTransactionResponse.fromJson(
                  _readJsonMap(item),
                ),
              )
              .toList(growable: false);
        }

        throw const FormatException('Expected a JSON array.');
      },
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
RecurringTransactionsApi recurringTransactionsApi(Ref ref) {
  return RecurringTransactionsApi(ref.watch(apiClientProvider));
}
