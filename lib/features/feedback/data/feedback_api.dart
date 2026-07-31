import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/feedback/data/dto/feedback_response.dart';
import 'package:saveapenny/features/feedback/data/dto/submit_feedback_request.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';

part 'feedback_api.g.dart';

class FeedbackApi {
  FeedbackApi(this._apiClient);

  final ApiClient _apiClient;

  Future<FeedbackResponse> submit(SubmitFeedbackRequest request) {
    return _apiClient.send<FeedbackResponse>(
      call: (dio) => dio.post<dynamic>('/feedback', data: request.toJson()),
      fromData: (data) => FeedbackResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<PaginatedData<FeedbackResponse>> list({
    FeedbackType? type,
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) {
    return _apiClient.send<PaginatedData<FeedbackResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/feedback',
        queryParameters: <String, Object?>{
          'type': type == null ? null : _feedbackTypeQuery(type),
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) => PaginatedData<FeedbackResponse>.fromJson(
        _readJsonMap(data),
        (item) => FeedbackResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<FeedbackResponse> getById(String feedbackId) {
    return _apiClient.send<FeedbackResponse>(
      call: (dio) => dio.get<dynamic>('/feedback/$feedbackId'),
      fromData: (data) => FeedbackResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> delete(String feedbackId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>('/feedback/$feedbackId'),
      fromData: (_) {},
    );
  }
}

String _feedbackTypeQuery(FeedbackType value) {
  return switch (value) {
    FeedbackType.general => 'GENERAL',
    FeedbackType.featureRequest => 'FEATURE_REQUEST',
    FeedbackType.bugReport => 'BUG_REPORT',
  };
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
FeedbackApi feedbackApi(Ref ref) {
  return FeedbackApi(ref.watch(apiClientProvider));
}
