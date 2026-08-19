import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/ui/app_dropdown_field.dart';
import 'package:saveapenny/features/insights/data/insights_repository.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/features/insights/domain/insights_repository.dart';
import 'package:saveapenny/features/insights/presentation/insight_detail_screen.dart';
import 'package:saveapenny/features/insights/presentation/insights_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _MutableInsightsRepository implements InsightsRepository {
  _MutableInsightsRepository(List<Insight> items, {this.failList = false})
    : _items = List<Insight>.of(items);

  final List<Insight> _items;
  final bool failList;

  InsightType? lastType;
  InsightSeverity? lastSeverity;
  bool? lastIsRead;
  int generateCalls = 0;

  @override
  Future<Insight> dismiss(String insightId) async {
    final index = _items.indexWhere((item) => item.id == insightId);
    _items[index] = _items[index].copyWith(dismissed: true);
    return _items[index];
  }

  @override
  Future<int> generate({InsightType? type}) async {
    generateCalls += 1;
    _items.insert(
      0,
      _insight(
        id: 'generated-$generateCalls',
        title: 'New insight $generateCalls',
        summary: 'The backend generated a fresh observation.',
        type: type ?? InsightType.recommendation,
        severity: InsightSeverity.info,
      ),
    );
    return 1;
  }

  @override
  Future<Insight> getInsight(String insightId) async {
    return _items.firstWhere((item) => item.id == insightId);
  }

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
    if (failList) {
      throw const Failure.network();
    }

    lastType = type;
    lastSeverity = severity;
    lastIsRead = isRead;

    final filtered = _items
        .where((item) {
          if (type != null && item.type != type) {
            return false;
          }
          if (severity != null && item.severity != severity) {
            return false;
          }
          if (isRead != null && item.read != isRead) {
            return false;
          }
          return true;
        })
        .toList(growable: false);

    return PaginatedData<Insight>(
      items: filtered,
      page: page,
      size: size,
      totalItems: filtered.length,
      totalPages: 1,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<Insight> markRead(String insightId) async {
    final index = _items.indexWhere((item) => item.id == insightId);
    _items[index] = _items[index].copyWith(read: true);
    return _items[index];
  }
}

Insight _insight({
  required String id,
  required String title,
  required String summary,
  InsightType type = InsightType.trend,
  InsightSeverity severity = InsightSeverity.warning,
  bool read = false,
  bool dismissed = false,
  String? detail,
}) {
  return Insight(
    id: id,
    type: type,
    title: title,
    summary: summary,
    detail: detail,
    categoryId: 'cat-1',
    severity: severity,
    metadata: '{"source":"test"}',
    read: read,
    dismissed: dismissed,
    generatedAt: DateTime.utc(2026, 7, 12, 10),
    createdAt: DateTime.utc(2026, 7, 12, 10),
  );
}

Future<void> _pumpInsightsApp(
  WidgetTester tester,
  ProviderContainer container,
) async {
  final router = GoRouter(
    initialLocation: '/insights',
    routes: <RouteBase>[
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/insights/:insightId',
        builder: (context, state) =>
            InsightDetailScreen(insightId: state.pathParameters['insightId']!),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('insights screen shows the empty state', (
    WidgetTester tester,
  ) async {
    final repository = _MutableInsightsRepository(const <Insight>[]);
    final container = ProviderContainer(
      overrides: [insightsRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);

    await _pumpInsightsApp(tester, container);

    expect(find.text('No insights yet'), findsOneWidget);
    expect(
      find.textContaining('Generate insights or wait for the backend schedule'),
      findsOneWidget,
    );
  });

  testWidgets('insights screen shows the shared error state', (
    WidgetTester tester,
  ) async {
    final repository = _MutableInsightsRepository(
      const <Insight>[],
      failList: true,
    );
    final container = ProviderContainer(
      overrides: [insightsRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);

    await _pumpInsightsApp(tester, container);

    expect(find.text('Connection problem'), findsOneWidget);
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('generate action shows success feedback and refreshes the list', (
    WidgetTester tester,
  ) async {
    final repository = _MutableInsightsRepository(const <Insight>[]);
    final container = ProviderContainer(
      overrides: [insightsRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);

    await _pumpInsightsApp(tester, container);

    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Generated 1 new insights.'), findsOneWidget);
    expect(find.text('New insight 1'), findsOneWidget);
  });

  testWidgets('selecting type and severity filters reloads the feed', (
    WidgetTester tester,
  ) async {
    final repository = _MutableInsightsRepository(<Insight>[
      _insight(
        id: 'a',
        title: 'Trend item',
        summary: 'Increasing category spend.',
        type: InsightType.trend,
        severity: InsightSeverity.warning,
      ),
      _insight(
        id: 'b',
        title: 'Info recommendation',
        summary: 'Budget advice from the backend.',
        type: InsightType.recommendation,
        severity: InsightSeverity.info,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [insightsRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);

    await _pumpInsightsApp(tester, container);

    await tester.tap(find.byType(AppDropdownField<InsightType?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trend').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppDropdownField<InsightSeverity?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Warning').last);
    await tester.pumpAndSettle();

    expect(repository.lastType, InsightType.trend);
    expect(repository.lastSeverity, InsightSeverity.warning);
    expect(find.text('Trend item'), findsOneWidget);
    expect(find.text('Info recommendation'), findsNothing);
  });

  testWidgets('tapping an unread insight marks it read and opens detail', (
    WidgetTester tester,
  ) async {
    final repository = _MutableInsightsRepository(<Insight>[
      _insight(
        id: 'detail-1',
        title: 'Dining out is climbing',
        summary: 'Your dining spend increased for three months.',
        detail: 'This may be seasonal or worth a closer review.',
      ),
    ]);
    final container = ProviderContainer(
      overrides: [insightsRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);

    await _pumpInsightsApp(tester, container);

    await tester.tap(find.text('Dining out is climbing'));
    await tester.pumpAndSettle();

    expect(find.text('Insight details'), findsOneWidget);
    expect(
      find.text('This may be seasonal or worth a closer review.'),
      findsOneWidget,
    );
    expect(repository._items.single.read, isTrue);
  });

  testWidgets(
    'dismissing from the detail screen returns to the list and removes the item',
    (WidgetTester tester) async {
      final repository = _MutableInsightsRepository(<Insight>[
        _insight(
          id: 'detail-2',
          title: 'Large grocery purchase',
          summary: 'One transaction was much larger than usual.',
          detail: 'Consider whether this was a bulk purchase.',
        ),
      ]);
      final container = ProviderContainer(
        overrides: [
          insightsRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      await _pumpInsightsApp(tester, container);

      await tester.tap(find.text('Large grocery purchase'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dismiss insight'));
      await tester.pumpAndSettle();

      expect(find.text('Insight details'), findsNothing);
      expect(find.text('Large grocery purchase'), findsNothing);
    },
  );
}
