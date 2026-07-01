import 'package:saveapenny/core/network/api_error_code.dart';

class ApiEnvelope<T> {
  ApiEnvelope({
    required this.success,
    required this.data,
    required this.error,
    required this.timestamp,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data) fromData,
  ) {
    final success = json['success'] as bool? ?? false;

    return ApiEnvelope<T>(
      success: success,
      data: success ? fromData(json['data']) : null,
      error: _readNullableMap(json['error']) == null
          ? null
          : ApiError.fromJson(_readNullableMap(json['error'])!),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
    );
  }

  final bool success;
  final T? data;
  final ApiError? error;
  final DateTime? timestamp;

  bool get isError => !success;

  T get requireData {
    if (isError) {
      throw StateError('Cannot read envelope data from an error response.');
    }
    return data as T;
  }
}

class ApiError {
  ApiError({
    required this.code,
    required this.rawCode,
    required this.message,
    required this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final rawCode = json['code'] as String?;
    final rawDetails = json['details'];

    return ApiError(
      code: ApiErrorCode.fromWire(rawCode),
      rawCode: rawCode,
      message: json['message'] as String? ?? '',
      details: rawDetails is List<Object?>
          ? rawDetails.whereType<String>().toList(growable: false)
          : const <String>[],
    );
  }

  final ApiErrorCode code;
  final String? rawCode;
  final String message;
  final List<String> details;
}

class PaginatedData<T> {
  PaginatedData({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? item) fromItem,
  ) {
    final rawItems = json['items'];
    final items = rawItems is List<Object?>
        ? rawItems.map(fromItem).toList(growable: false)
        : <T>[];

    return PaginatedData<T>(
      items: items,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );
  }

  final List<T> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
}

Map<String, dynamic>? _readNullableMap(Object? value) {
  if (value is Map<Object?, Object?>) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }

  return null;
}
