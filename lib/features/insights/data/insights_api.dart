import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/insights/data/dto/generate_insights_request.dart';
import 'package:saveapenny/features/insights/data/dto/generate_insights_response.dart';
import 'package:saveapenny/features/insights/data/dto/insight_json.dart';
import 'package:saveapenny/features/insights/data/dto/insight_response.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';

part 'insights_api.g.dart';

class InsightsApi {
  InsightsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedData<InsightResponse>> list({
    InsightType? type,
    InsightSeverity? severity,
    bool? isRead,
    int page = 0,
    int size = 20,
    String sortBy = 'generatedAt',
    String sortDir = 'desc',
  }) {
    return _apiClient.send<PaginatedData<InsightResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/insights',
        queryParameters: <String, Object?>{
          'type': type == null ? null : insightTypeToJson(type),
          'severity': severity == null ? null : insightSeverityToJson(severity),
          'isRead': isRead,
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDir': sortDir,
        },
      ),
      fromData: (data) => PaginatedData<InsightResponse>.fromJson(
        _readJsonMap(data),
        (item) => InsightResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<InsightResponse> getInsight(String insightId) {
    return _apiClient.send<InsightResponse>(
      call: (dio) => dio.get<dynamic>('/insights/$insightId'),
      fromData: (data) => InsightResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<InsightResponse> markRead(String insightId) {
    return _apiClient.send<InsightResponse>(
      call: (dio) => dio.patch<dynamic>('/insights/$insightId/read'),
      fromData: (data) => InsightResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<InsightResponse> dismiss(String insightId) {
    return _apiClient.send<InsightResponse>(
      call: (dio) => dio.patch<dynamic>('/insights/$insightId/dismiss'),
      fromData: (data) => InsightResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<GenerateInsightsResponse> generate({InsightType? type}) {
    return _apiClient.send<GenerateInsightsResponse>(
      call: (dio) => dio.post<dynamic>(
        '/insights/generate',
        data: type == null
            ? null
            : GenerateInsightsRequest(type: type).toJson(),
      ),
      fromData: (data) => GenerateInsightsResponse.fromJson(_readJsonMap(data)),
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
InsightsApi insightsApi(Ref ref) {
  return InsightsApi(ref.watch(apiClientProvider));
}
