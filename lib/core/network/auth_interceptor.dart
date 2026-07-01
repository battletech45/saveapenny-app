import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';

typedef SessionExpiredCallback = Future<void> Function();

Options skipAuthInterceptor([Options? options]) {
  return (options ?? Options()).copyWith(
    extra: <String, Object?>{...?options?.extra, _skipAuthInterceptorKey: true},
  );
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._tokenStore,
    required this._refreshDio,
    this.onSessionExpired,
  });

  final SecureTokenStore _tokenStore;
  final Dio _refreshDio;
  final SessionExpiredCallback? onSessionExpired;

  Future<void>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[_skipAuthInterceptorKey] == true) {
      handler.next(options);
      return;
    }

    try {
      final accessToken = await _tokenStore.readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        handler.next(options);
        return;
      }

      if (_shouldRefreshAccessToken(accessToken)) {
        await _refreshTokens();
      }

      final latestAccessToken = await _tokenStore.readAccessToken();
      if (latestAccessToken != null && latestAccessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $latestAccessToken';
      }

      handler.next(options);
    } on DioException catch (error) {
      handler.reject(error);
    } on FormatException catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetryUnauthorized(err)) {
      try {
        await _refreshTokens();
        final latestAccessToken = await _tokenStore.readAccessToken();
        if (latestAccessToken == null || latestAccessToken.isEmpty) {
          handler.next(err);
          return;
        }

        final retriedOptions = err.requestOptions.copyWith(
          extra: <String, Object?>{
            ...err.requestOptions.extra,
            _retriedAfterRefreshKey: true,
          },
          headers: <String, Object?>{
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $latestAccessToken',
          },
        );

        final response = await _refreshDio.fetch<dynamic>(retriedOptions);
        handler.resolve(response);
        return;
      } on DioException {
        await _expireSession();
      }
    }

    handler.next(err);
  }

  bool _shouldRefreshAccessToken(String accessToken) {
    final expiration = _readJwtExpiration(accessToken);
    if (expiration == null) {
      return false;
    }

    return expiration.difference(DateTime.now().toUtc()) <=
        const Duration(seconds: 60);
  }

  bool _shouldRetryUnauthorized(DioException error) {
    return error.response?.statusCode == 401 &&
        error.requestOptions.extra[_retriedAfterRefreshKey] != true &&
        !error.requestOptions.path.endsWith('/auth/refresh');
  }

  Future<void> _refreshTokens() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<void> _performRefresh() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession();
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 401,
        ),
      );
    }

    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: <String, String>{'refreshToken': refreshToken},
      options: Options(
        extra: const <String, Object?>{_skipAuthInterceptorKey: true},
      ),
    );

    final rawJson = response.data;
    if (rawJson is! Map<Object?, Object?>) {
      await _expireSession();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    final responseJson = rawJson as Map<Object?, Object?>;
    final envelope = ApiEnvelope<Map<String, dynamic>>.fromJson(
      responseJson.map((key, value) => MapEntry(key.toString(), value)),
      (data) {
        if (data is Map<Object?, Object?>) {
          return data.map((key, value) => MapEntry(key.toString(), value));
        }

        return <String, dynamic>{};
      },
    );
    if (envelope.isError) {
      await _expireSession();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    final tokenJson = envelope.requireData;
    final accessToken = tokenJson['accessToken'] as String?;
    final nextRefreshToken = tokenJson['refreshToken'] as String?;
    if (accessToken == null || nextRefreshToken == null) {
      await _expireSession();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    await _tokenStore.writeTokens(
      accessToken: accessToken,
      refreshToken: nextRefreshToken,
    );
  }

  Future<void> _expireSession() async {
    await _tokenStore.clearTokens();
    if (onSessionExpired != null) {
      await onSessionExpired!();
    }
  }

  DateTime? _readJwtExpiration(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final json = jsonDecode(payload);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final expiration = json['exp'];
    if (expiration is! num) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      expiration.toInt() * 1000,
      isUtc: true,
    );
  }
}

const String _skipAuthInterceptorKey = '_skipAuthInterceptor';
const String _retriedAfterRefreshKey = '_retriedAfterRefresh';
