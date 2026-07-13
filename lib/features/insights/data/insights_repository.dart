import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/insights/data/dto/insight_response.dart';
import 'package:saveapenny/features/insights/data/insights_api.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/features/insights/domain/insights_repository.dart';

part 'insights_repository.g.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  const InsightsRepositoryImpl(this._insightsApi);

  final InsightsApi _insightsApi;

  @override
  Future<PaginatedData<Insight>> list({
    InsightType? type,
    InsightSeverity? severity,
    bool? isRead,
    int page = 0,
    int size = 20,
    String sortBy = 'generatedAt',
    String sortDir = 'desc',
  }) async {
    final response = await _insightsApi.list(
      type: type,
      severity: severity,
      isRead: isRead,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
    );

    return PaginatedData<Insight>(
      items: response.items
          .map((InsightResponse item) => item.toDomain())
          .toList(growable: false),
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  @override
  Future<Insight> getInsight(String insightId) async {
    final response = await _insightsApi.getInsight(insightId);
    return response.toDomain();
  }

  @override
  Future<Insight> markRead(String insightId) async {
    final response = await _insightsApi.markRead(insightId);
    return response.toDomain();
  }

  @override
  Future<Insight> dismiss(String insightId) async {
    final response = await _insightsApi.dismiss(insightId);
    return response.toDomain();
  }

  @override
  Future<int> generate({InsightType? type}) async {
    final response = await _insightsApi.generate(type: type);
    return response.generatedCount;
  }
}

@Riverpod(keepAlive: true)
InsightsRepository insightsRepository(Ref ref) {
  return InsightsRepositoryImpl(ref.watch(insightsApiProvider));
}
