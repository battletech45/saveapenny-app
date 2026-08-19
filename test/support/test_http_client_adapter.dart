import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class TestHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = <RequestOptions>[];
  final Map<String, List<_QueuedAdapterResponse>> _responses =
      <String, List<_QueuedAdapterResponse>>{};

  void enqueueJson({
    required String path,
    required int statusCode,
    required Object? body,
    Map<String, List<String>> headers = const <String, List<String>>{},
  }) {
    final queue = _responses.putIfAbsent(
      path,
      () => <_QueuedAdapterResponse>[],
    );
    queue.add(
      _QueuedAdapterResponse(
        statusCode: statusCode,
        body: body,
        headers: headers,
      ),
    );
  }

  /// Simulates a transport-level failure (no response reaches the app),
  /// e.g. [DioExceptionType.connectionError] for "device is offline" —
  /// [ApiClient.send] maps this to [Failure.network].
  void enqueueError({required String path, required DioExceptionType type}) {
    final queue = _responses.putIfAbsent(
      path,
      () => <_QueuedAdapterResponse>[],
    );
    queue.add(_QueuedAdapterResponse(statusCode: 0, body: null, type: type));
  }

  List<RequestOptions> requestsForPath(String path) {
    return requests.where((request) => request.path == path).toList();
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final queue = _responses[options.path];
    if (queue == null || queue.isEmpty) {
      throw StateError('No queued response for ${options.path}.');
    }

    final response = queue.removeAt(0);
    if (response.type != null) {
      throw DioException(requestOptions: options, type: response.type!);
    }

    final headers = <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      ...response.headers,
    };

    return ResponseBody.fromString(
      jsonEncode(response.body),
      response.statusCode,
      headers: headers,
    );
  }
}

class _QueuedAdapterResponse {
  const _QueuedAdapterResponse({
    required this.statusCode,
    required this.body,
    this.headers = const <String, List<String>>{},
    this.type,
  });

  final int statusCode;
  final Object? body;
  final Map<String, List<String>> headers;
  final DioExceptionType? type;
}
