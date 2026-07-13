import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/insights/application/insights_controller.dart';
import 'package:saveapenny/features/insights/data/insights_repository.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/features/insights/domain/insights_repository.dart';

class _FakeInsightsRepository implements InsightsRepository {
  _FakeInsightsRepository({
    this.onList,
    this.onGetInsight,
    this.onMarkRead,
    this.onDismiss,
    this.onGenerate,
  });

  final Future<PaginatedData<Insight>> Function({
    InsightType? type,
    InsightSeverity? severity,
    bool? isRead,
    int page,
    int size,
    String sortBy,
    String sortDir,
  })?
  onList;
  final Future<Insight> Function(String insightId)? onGetInsight;
  final Future<Insight> Function(String insightId)? onMarkRead;
  final Future<Insight> Function(String insightId)? onDismiss;
  final Future<int> Function({InsightType? type})? onGenerate;

  @override
  Future<Insight> dismiss(String insightId) => onDismiss!(insightId);

  @override
  Future<int> generate({InsightType? type}) => onGenerate!(type: type);

  @override
  Future<Insight> getInsight(String insightId) => onGetInsight!(insightId);

  @override
  Future<PaginatedData<Insight>> list({
    InsightType? type,
    InsightSeverity? severity,
    bool? isRead,
    int page = 0,
    int size = 20,
    String sortBy = 'generatedAt',
    String sortDir = 'desc',
  }) {
    return onList!(
      type: type,
      severity: severity,
      isRead: isRead,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
    );
  }

  @override
  Future<Insight> markRead(String insightId) => onMarkRead!(insightId);
}

void main() {
  test('build loads the first page of insights', () async {
    final container = ProviderContainer(
      overrides: [
        insightsRepositoryProvider.overrideWith(
          (ref) => _FakeInsightsRepository(
            onList:
                ({
                  type,
                  severity,
                  isRead,
                  page = 0,
                  size = 20,
                  sortBy = 'generatedAt',
                  sortDir = 'desc',
                }) async => PaginatedData<Insight>(
                  items: <Insight>[
                    Insight(
                      id: 'ins-1',
                      type: InsightType.trend,
                      title: 'Dining out is climbing',
                      summary: 'Your dining spend increased for three months.',
                      detail: null,
                      categoryId: 'cat-2',
                      severity: InsightSeverity.warning,
                      metadata: null,
                      read: false,
                      dismissed: false,
                      generatedAt: DateTime.utc(2026, 7, 12, 10),
                      createdAt: DateTime.utc(2026, 7, 12, 10),
                    ),
                  ],
                  page: page,
                  size: size,
                  totalItems: 1,
                  totalPages: 1,
                  hasNext: false,
                  hasPrevious: false,
                ),
            onGetInsight: (_) async => throw UnimplementedError(),
            onMarkRead: (insightId) async => throw UnimplementedError(),
            onDismiss: (insightId) async => throw UnimplementedError(),
            onGenerate: ({type}) async => 1,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(insightsControllerProvider.future);

    expect(state.items, hasLength(1));
    expect(state.items.single.type, InsightType.trend);
    expect(state.unreadOnly, isFalse);
  });

  test('build exposes the primary failure path when listing fails', () async {
    final container = ProviderContainer(
      overrides: [
        insightsRepositoryProvider.overrideWith(
          (ref) => _FakeInsightsRepository(
            onList:
                ({
                  type,
                  severity,
                  isRead,
                  page = 0,
                  size = 20,
                  sortBy = 'generatedAt',
                  sortDir = 'desc',
                }) async {
                  throw const Failure.network();
                },
            onGetInsight: (_) async => throw UnimplementedError(),
            onMarkRead: (insightId) async => throw UnimplementedError(),
            onDismiss: (insightId) async => throw UnimplementedError(),
            onGenerate: ({type}) async => 1,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(insightsControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(insightsControllerProvider).hasError, isTrue);
    expect(
      container.read(insightsControllerProvider).error,
      isA<NetworkFailure>(),
    );
  });

  test('setFilters reloads the first page with the selected filters', () async {
    InsightType? requestedType;
    InsightSeverity? requestedSeverity;

    final container = ProviderContainer(
      overrides: [
        insightsRepositoryProvider.overrideWith(
          (ref) => _FakeInsightsRepository(
            onList:
                ({
                  type,
                  severity,
                  isRead,
                  page = 0,
                  size = 20,
                  sortBy = 'generatedAt',
                  sortDir = 'desc',
                }) async {
                  requestedType = type;
                  requestedSeverity = severity;
                  return PaginatedData<Insight>(
                    items: const <Insight>[],
                    page: page,
                    size: size,
                    totalItems: 0,
                    totalPages: 0,
                    hasNext: false,
                    hasPrevious: false,
                  );
                },
            onGetInsight: (_) async => throw UnimplementedError(),
            onMarkRead: (insightId) async => throw UnimplementedError(),
            onDismiss: (insightId) async => throw UnimplementedError(),
            onGenerate: ({type}) async => 0,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(insightsControllerProvider.future);
    await container
        .read(insightsControllerProvider.notifier)
        .setFilters(type: InsightType.trend, severity: InsightSeverity.warning);

    final state = container.read(insightsControllerProvider).requireValue;
    expect(requestedType, InsightType.trend);
    expect(requestedSeverity, InsightSeverity.warning);
    expect(state.type, InsightType.trend);
    expect(state.severity, InsightSeverity.warning);
  });
}
