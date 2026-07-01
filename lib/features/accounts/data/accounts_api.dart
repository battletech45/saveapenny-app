import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/accounts/data/dto/account_response.dart';
import 'package:saveapenny/features/accounts/data/dto/create_account_request.dart';
import 'package:saveapenny/features/accounts/data/dto/update_account_request.dart';

part 'accounts_api.g.dart';

class AccountsApi {
  const AccountsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedData<AccountResponse>> list() {
    return _apiClient.send<PaginatedData<AccountResponse>>(
      call: (dio) => dio.get<dynamic>('/accounts'),
      fromData: (data) => PaginatedData<AccountResponse>.fromJson(
        _readJsonMap(data),
        (item) => AccountResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<AccountResponse> create(CreateAccountRequest request) {
    return _apiClient.send<AccountResponse>(
      call: (dio) => dio.post<dynamic>('/accounts', data: request.toJson()),
      fromData: (data) => AccountResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<AccountResponse> update({
    required String accountId,
    required UpdateAccountRequest request,
  }) {
    return _apiClient.send<AccountResponse>(
      call: (dio) => dio.put<dynamic>(
        '/accounts/$accountId',
        data: request.toJson(),
      ),
      fromData: (data) => AccountResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> delete(String accountId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>('/accounts/$accountId'),
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
AccountsApi accountsApi(Ref ref) {
  return AccountsApi(ref.watch(apiClientProvider));
}
