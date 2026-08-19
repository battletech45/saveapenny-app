import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/push/push_messaging_gateway.dart';
import 'package:saveapenny/core/storage/cache_encryption_key_provider.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/auth/data/auth_api.dart';
import 'package:saveapenny/features/auth/data/dto/auth_token_response.dart';
import 'package:saveapenny/features/auth/data/dto/login_request.dart';
import 'package:saveapenny/features/auth/data/dto/logout_request.dart';
import 'package:saveapenny/features/auth/data/dto/refresh_token_request.dart';
import 'package:saveapenny/features/auth/data/dto/register_request.dart';
import 'package:saveapenny/features/auth/domain/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_session.dart';
import 'package:saveapenny/features/push/data/device_token_api.dart';

part 'auth_repository.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._authApi,
    this._tokenStore,
    this._deviceTokenApi,
    this._pushMessagingGateway,
    this._cacheEncryptionKeyProvider,
    this._responseCacheStore,
  );

  final AuthApi _authApi;
  final SecureTokenStore _tokenStore;
  final DeviceTokenApi _deviceTokenApi;
  final PushMessagingGateway _pushMessagingGateway;
  final CacheEncryptionKeyProvider _cacheEncryptionKeyProvider;
  final ResponseCacheStore _responseCacheStore;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _authApi.register(
      RegisterRequest(email: email, password: password, fullName: fullName),
    );

    await _tokenStore.writeTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return response.toDomain();
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _authApi.login(
      LoginRequest(email: email, password: password),
    );

    await _tokenStore.writeTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return response.toDomain();
  }

  @override
  Future<AuthSession> refresh() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const Failure.unauthenticated();
    }

    final response = await _authApi.refresh(
      RefreshTokenRequest(refreshToken: refreshToken),
    );

    await _tokenStore.writeTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return response.toDomain();
  }

  @override
  Future<void> logout() async {
    await _unregisterDeviceToken();

    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _authApi.logout(LogoutRequest(refreshToken: refreshToken));
    }

    await _tokenStore.clearTokens();
    // Purge the offline cache alongside the tokens: a shared/reused device
    // must not let the next login read this user's cached financial data,
    // and the ciphertext is unrecoverable once the key is gone regardless.
    // See docs/adr/0003-offline-read-cache.md.
    await _responseCacheStore.clearAll();
    await _cacheEncryptionKeyProvider.delete();
  }

  Future<void> _unregisterDeviceToken() async {
    try {
      final token = await _pushMessagingGateway.getToken();
      if (token == null) {
        return;
      }
      await _deviceTokenApi.unregister(token);
    } on Object catch (error) {
      developer.log(
        'Failed to unregister FCM device token on logout: $error',
        name: 'push',
      );
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authApiProvider),
    ref.watch(secureTokenStoreProvider),
    ref.watch(deviceTokenApiProvider),
    ref.watch(pushMessagingGatewayProvider),
    ref.watch(cacheEncryptionKeyProviderProvider),
    ref.watch(responseCacheStoreProvider),
  );
}
