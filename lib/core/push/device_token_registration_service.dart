import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/push/data/device_token_api.dart';
import 'package:saveapenny/features/push/data/dto/register_device_token_request.dart';

part 'device_token_registration_service.g.dart';

/// Registers this device's FCM token against the signed-in user.
abstract interface class DeviceTokenRegistrationService {
  Future<void> register(String token);
}

class DioDeviceTokenRegistrationService
    implements DeviceTokenRegistrationService {
  const DioDeviceTokenRegistrationService(this._deviceTokenApi);

  final DeviceTokenApi _deviceTokenApi;

  @override
  Future<void> register(String token) async {
    final platform = _currentPlatform();
    if (platform == null) {
      return;
    }

    try {
      await _deviceTokenApi.register(
        RegisterDeviceTokenRequest(token: token, platform: platform),
      );
    } on Object catch (error) {
      developer.log(
        'Failed to register FCM device token: $error',
        name: 'push',
      );
    }
  }

  String? _currentPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ANDROID';
      case TargetPlatform.iOS:
        return 'IOS';
      default:
        return null;
    }
  }
}

@Riverpod(keepAlive: true)
DeviceTokenRegistrationService deviceTokenRegistrationService(Ref ref) {
  return DioDeviceTokenRegistrationService(ref.watch(deviceTokenApiProvider));
}
