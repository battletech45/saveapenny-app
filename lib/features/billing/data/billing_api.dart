import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/billing/data/dto/entitlement_response.dart';

part 'billing_api.g.dart';

class BillingApi {
  BillingApi(this._apiClient);

  final ApiClient _apiClient;

  Future<EntitlementResponse> getEntitlement() {
    return _apiClient.send<EntitlementResponse>(
      call: (dio) => dio.get<dynamic>('/billing/entitlement'),
      fromData: (data) =>
          EntitlementResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<EntitlementResponse> sync() {
    return _apiClient.send<EntitlementResponse>(
      call: (dio) => dio.post<dynamic>('/billing/sync'),
      fromData: (data) =>
          EntitlementResponse.fromJson(data as Map<String, dynamic>),
    );
  }
}

@Riverpod(keepAlive: true)
BillingApi billingApi(Ref ref) {
  return BillingApi(ref.watch(apiClientProvider));
}
