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
    required this.headers,
  });

  final int statusCode;
  final Object? body;
  final Map<String, List<String>> headers;
}
