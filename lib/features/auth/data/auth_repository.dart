import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/auth/data/auth_api.dart';
import 'package:saveapenny/features/auth/data/dto/auth_token_response.dart';
import 'package:saveapenny/features/auth/data/dto/login_request.dart';
import 'package:saveapenny/features/auth/data/dto/logout_request.dart';
import 'package:saveapenny/features/auth/data/dto/refresh_token_request.dart';
import 'package:saveapenny/features/auth/data/dto/register_request.dart';
import 'package:saveapenny/features/auth/domain/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_session.dart';

part 'auth_repository.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._authApi, this._tokenStore);

  final AuthApi _authApi;
  final SecureTokenStore _tokenStore;

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
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStore.clearTokens();
      return;
    }

    await _authApi.logout(LogoutRequest(refreshToken: refreshToken));
    await _tokenStore.clearTokens();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authApiProvider),
    ref.watch(secureTokenStoreProvider),
  );
}
