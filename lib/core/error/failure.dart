import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure implements Exception {
  const factory Failure.network({String? message}) = NetworkFailure;

  const factory Failure.api({
    required ApiErrorCode code,
    required String message,
    @Default(<String>[]) List<String> details,
  }) = ApiFailure;

  const factory Failure.unauthenticated({ApiErrorCode? code, String? message}) =
      UnauthenticatedFailure;

  const factory Failure.rateLimited({
    required ApiErrorCode code,
    String? message,
    Duration? retryAfter,
  }) = RateLimitedFailure;

  const factory Failure.unknown({String? message}) = UnknownFailure;
}

abstract final class FailureMapper {
  static Failure fromApiError(ApiError error) {
    if (error.code == ApiErrorCode.rateLimited ||
        error.code == ApiErrorCode.stockRateLimitExceeded) {
      return Failure.rateLimited(code: error.code, message: error.message);
    }

    if (error.code.isAuthExpiry) {
      return Failure.unauthenticated(code: error.code, message: error.message);
    }

    return Failure.api(
      code: error.code,
      message: error.message,
      details: error.details,
    );
  }

  static Failure fromDio(DioException exception) {
    final response = exception.response;
    final apiError = _readApiError(response?.data);

    if (apiError != null) {
      final failure = fromApiError(apiError);
      if (failure is RateLimitedFailure) {
        return failure.copyWith(retryAfter: _parseRetryAfter(response));
      }
      return failure;
    }

    if (response?.statusCode == 401) {
      return const Failure.unauthenticated();
    }

    if (response?.statusCode == 429) {
      return Failure.rateLimited(
        code: ApiErrorCode.rateLimited,
        retryAfter: _parseRetryAfter(response),
      );
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => Failure.network(
        message: exception.message,
      ),
      DioExceptionType.transformTimeout => Failure.network(
        message: exception.message,
      ),
      DioExceptionType.cancel => const Failure.unknown(),
      DioExceptionType.badResponse => Failure.unknown(
        message: exception.message,
      ),
      DioExceptionType.unknown => Failure.unknown(message: exception.message),
    };
  }

  static ApiError? _readApiError(Object? data) {
    if (data is! Map<Object?, Object?>) {
      return null;
    }

    final json = data.map((key, value) => MapEntry(key.toString(), value));
    final errorJson = json['error'];
    if (errorJson is! Map<Object?, Object?>) {
      return null;
    }

    return ApiError.fromJson(
      errorJson.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  static Duration? _parseRetryAfter(Response<dynamic>? response) {
    final values = response?.headers.map['retry-after'];
    final seconds = values == null || values.isEmpty
        ? null
        : int.tryParse(values.first);

    if (seconds == null) {
      return null;
    }

    return Duration(seconds: seconds);
  }
}
