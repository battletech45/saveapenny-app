import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/config/app_environment.dart';
import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/auth_interceptor.dart';
import 'package:saveapenny/core/router/app_router.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';

part 'dio_client.g.dart';

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<T> send<T>({
    required Future<Response<dynamic>> Function(Dio dio) call,
    required T Function(Object? data) fromData,
  }) async {
    try {
      final response = await call(_dio);
      final rawJson = response.data;
      if (rawJson is! Map<Object?, Object?>) {
        throw const Failure.unknown();
      }

      final envelope = ApiEnvelope<T>.fromJson(
        rawJson.map((key, value) => MapEntry(key.toString(), value)),
        fromData,
      );
      if (envelope.isError) {
        final apiError = envelope.error;
        if (apiError != null) {
          throw FailureMapper.fromApiError(apiError);
        }
        throw const Failure.unknown();
      }
      return envelope.requireData;
    } on DioException catch (error) {
      throw FailureMapper.fromDio(error);
    }
  }
}

@Riverpod(keepAlive: true)
AppEnvironment appEnvironment(Ref ref) {
  return AppEnvironment.current();
}

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final tokenStore = ref.watch(secureTokenStoreProvider);

  final options = BaseOptions(
    baseUrl: environment.apiRoot,
    connectTimeout: environment.connectTimeout,
    receiveTimeout: environment.receiveTimeout,
    sendTimeout: environment.sendTimeout,
    headers: const <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  final dio = Dio(options);
  final refreshDio = Dio(options);

  dio.interceptors.add(
    AuthInterceptor(
      tokenStore: tokenStore,
      refreshDio: refreshDio,
      onSessionExpired: () async {
        ref.read(authSessionControllerProvider.notifier).setUnauthenticated();
      },
    ),
  );

  return dio;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(ref.watch(dioProvider));
}
