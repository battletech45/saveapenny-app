import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';

abstract interface class InsightsRepository {
  Future<PaginatedData<Insight>> list({
    InsightType? type,
    InsightSeverity? severity,
    bool? isRead,
    int page = 0,
    int size = 20,
    String sortBy = 'generatedAt',
    String sortDir = 'desc',
  });

  Future<Insight> getInsight(String insightId);

  Future<Insight> markRead(String insightId);

  Future<Insight> dismiss(String insightId);

  Future<int> generate({InsightType? type});
}
