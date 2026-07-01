import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/auth/domain/auth_session.dart';

part 'auth_token_response.freezed.dart';
part 'auth_token_response.g.dart';

@freezed
abstract class AuthTokenResponse with _$AuthTokenResponse {
  const factory AuthTokenResponse({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  }) = _AuthTokenResponse;

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenResponseFromJson(json);
}

extension AuthTokenResponseX on AuthTokenResponse {
  AuthSession toDomain() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
  }
}
