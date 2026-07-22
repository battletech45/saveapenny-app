import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_device_token_request.freezed.dart';
part 'register_device_token_request.g.dart';

@freezed
abstract class RegisterDeviceTokenRequest with _$RegisterDeviceTokenRequest {
  const factory RegisterDeviceTokenRequest({
    required String token,
    required String platform,
  }) = _RegisterDeviceTokenRequest;

  factory RegisterDeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterDeviceTokenRequestFromJson(json);
}
