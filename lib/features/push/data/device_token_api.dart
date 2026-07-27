import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/push/data/dto/register_device_token_request.dart';

part 'device_token_api.g.dart';

class DeviceTokenApi {
  const DeviceTokenApi(this._apiClient);

  final ApiClient _apiClient;

  Future<void> register(RegisterDeviceTokenRequest request) {
    return _apiClient.send<void>(
      call: (dio) =>
          dio.post<dynamic>('/users/me/device-tokens', data: request.toJson()),
      fromData: (_) {},
    );
  }

  Future<void> unregister(String token) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>(
        '/users/me/device-tokens',
        queryParameters: {'token': token},
      ),
      fromData: (_) {},
    );
  }
}

@Riverpod(keepAlive: true)
DeviceTokenApi deviceTokenApi(Ref ref) {
  return DeviceTokenApi(ref.watch(apiClientProvider));
}
