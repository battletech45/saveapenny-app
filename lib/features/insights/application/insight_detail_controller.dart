import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/insights/data/insights_repository.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';

part 'insight_detail_controller.g.dart';

@riverpod
class InsightDetailController extends _$InsightDetailController {
  @override
  Future<Insight> build(String insightId) {
    return _fetch(insightId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(insightId));
  }

  Future<Insight> _fetch(String insightId) async {
    final repository = ref.read(insightsRepositoryProvider);
    final insight = await repository.getInsight(insightId);

    if (insight.read) {
      return insight;
    }

    return repository.markRead(insightId);
  }
}
