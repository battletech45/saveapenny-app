import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/auth_interceptor.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/auth/data/dto/auth_token_response.dart';
import 'package:saveapenny/features/auth/data/dto/login_request.dart';
import 'package:saveapenny/features/auth/data/dto/logout_request.dart';
import 'package:saveapenny/features/auth/data/dto/refresh_token_request.dart';
import 'package:saveapenny/features/auth/data/dto/register_request.dart';

part 'auth_api.g.dart';

class AuthApi {
  const AuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthTokenResponse> register(RegisterRequest request) {
    return _apiClient.send<AuthTokenResponse>(
      call: (dio) => dio.post<dynamic>(
        '/auth/register',
        data: request.toJson(),
        options: skipAuthInterceptor(),
      ),
      fromData: (data) => AuthTokenResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<AuthTokenResponse> login(LoginRequest request) {
    return _apiClient.send<AuthTokenResponse>(
      call: (dio) => dio.post<dynamic>(
        '/auth/login',
        data: request.toJson(),
        options: skipAuthInterceptor(),
      ),
      fromData: (data) => AuthTokenResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<AuthTokenResponse> refresh(RefreshTokenRequest request) {
    return _apiClient.send<AuthTokenResponse>(
      call: (dio) => dio.post<dynamic>(
        '/auth/refresh',
        data: request.toJson(),
        options: skipAuthInterceptor(),
      ),
      fromData: (data) => AuthTokenResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> logout(LogoutRequest request) {
    return _apiClient.send<void>(
      call: (dio) => dio.post<dynamic>(
        '/auth/logout',
        data: request.toJson(),
        options: skipAuthInterceptor(),
      ),
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
AuthApi authApi(Ref ref) {
  return AuthApi(ref.watch(apiClientProvider));
}
