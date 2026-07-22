import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/push/device_token_registration_service.dart';
import 'package:saveapenny/features/push/data/device_token_api.dart';
import 'package:saveapenny/features/push/data/dto/register_device_token_request.dart';

class _MockDeviceTokenApi extends Mock implements DeviceTokenApi {}

void main() {
  late _MockDeviceTokenApi deviceTokenApi;
  late DioDeviceTokenRegistrationService service;

  setUpAll(() {
    registerFallbackValue(
      const RegisterDeviceTokenRequest(token: 'fallback', platform: 'ANDROID'),
    );
  });

  setUp(() {
    deviceTokenApi = _MockDeviceTokenApi();
    service = DioDeviceTokenRegistrationService(deviceTokenApi);
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('registers with ANDROID platform on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    when(() => deviceTokenApi.register(any())).thenAnswer((_) async {});

    await service.register('token-1');

    verify(
      () => deviceTokenApi.register(
        const RegisterDeviceTokenRequest(token: 'token-1', platform: 'ANDROID'),
      ),
    ).called(1);
  });

  test('registers with IOS platform on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    when(() => deviceTokenApi.register(any())).thenAnswer((_) async {});

    await service.register('token-2');

    verify(
      () => deviceTokenApi.register(
        const RegisterDeviceTokenRequest(token: 'token-2', platform: 'IOS'),
      ),
    ).called(1);
  });

  test('swallows a thrown Failure instead of rethrowing', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    when(
      () => deviceTokenApi.register(any()),
    ).thenThrow(const Failure.unknown(message: 'boom'));

    await expectLater(service.register('token-3'), completes);
  });

  test('skips the call on unsupported platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    await service.register('token-4');

    verifyNever(() => deviceTokenApi.register(any()));
  });
}
