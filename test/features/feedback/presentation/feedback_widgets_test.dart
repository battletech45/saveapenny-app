import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/feedback/data/feedback_metadata_builder.dart';
import 'package:saveapenny/features/feedback/data/feedback_repository.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';
import 'package:saveapenny/features/feedback/domain/feedback_repository.dart';
import 'package:saveapenny/features/feedback/presentation/feedback_screen.dart';
import 'package:saveapenny/features/feedback/presentation/widgets/feedback_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeFeedbackRepository implements FeedbackRepository {
  _FakeFeedbackRepository({
    required this.items,
    this.failList = false,
    this.onSubmit,
  });

  final List<Feedback> items;
  final bool failList;
  final Future<Feedback> Function({
    required FeedbackType type,
    int? rating,
    required String message,
    Map<String, dynamic>? metadata,
  })?
  onSubmit;

  @override
  Future<void> delete(String feedbackId) async {}

  @override
  Future<Feedback> getById(String feedbackId) async {
    return items.firstWhere((item) => item.id == feedbackId);
  }

  @override
  Future<PaginatedData<Feedback>> list({
    FeedbackType? type,
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    if (failList) {
      throw const Failure.network();
    }

    final filtered = type == null
        ? items
        : items.where((item) => item.type == type).toList(growable: false);

    return PaginatedData<Feedback>(
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
  Future<Feedback> submit({
    required FeedbackType type,
    int? rating,
    required String message,
    Map<String, dynamic>? metadata,
  }) {
    return onSubmit!(
      type: type,
      rating: rating,
      message: message,
      metadata: metadata,
    );
  }
}

class _FakeFeedbackMetadataBuilder implements FeedbackMetadataBuilder {
  const _FakeFeedbackMetadataBuilder();

  @override
  Future<Map<String, dynamic>> build({required String screen}) async {
    return <String, dynamic>{
      'platform': 'ios',
      'appVersion': '1.0.0',
      'screen': screen,
    };
  }
}

Feedback _feedback({required String id}) {
  return Feedback(
    id: id,
    userId: 'u-1',
    type: FeedbackType.general,
    rating: 4,
    message: 'Helpful app.',
    metadata: const <String, dynamic>{'screen': 'profile'},
    status: FeedbackStatus.open,
    createdAt: DateTime.parse('2026-07-31T10:00:00Z'),
    updatedAt: DateTime.parse('2026-07-31T10:00:00Z'),
  );
}

Future<void> _pumpWidget(
  WidgetTester tester, {
  required ProviderContainer container,
  required Widget child,
  bool wrapInScaffold = true,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: wrapInScaffold ? Scaffold(body: child) : child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('feedback form validates the required message field', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWith(
          (ref) => _FakeFeedbackRepository(
            items: const <Feedback>[],
            onSubmit:
                ({required type, rating, required message, metadata}) async =>
                    _feedback(id: 'f-1'),
          ),
        ),
        feedbackMetadataBuilderProvider.overrideWith(
          (ref) => const _FakeFeedbackMetadataBuilder(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(
      tester,
      container: container,
      child: const FeedbackFormSheet(sourceScreen: 'profile'),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Send feedback'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsOneWidget);
  });

  testWidgets('feedback form shows api validation failure copy', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWith(
          (ref) => _FakeFeedbackRepository(
            items: const <Feedback>[],
            onSubmit:
                ({required type, rating, required message, metadata}) async {
                  throw const Failure.api(
                    code: ApiErrorCode.validationFailed,
                    message: 'Validation failed.',
                  );
                },
          ),
        ),
        feedbackMetadataBuilderProvider.overrideWith(
          (ref) => const _FakeFeedbackMetadataBuilder(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(
      tester,
      container: container,
      child: const FeedbackFormSheet(sourceScreen: 'profile'),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'Please improve reports.',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Send feedback'));
    await tester.pumpAndSettle();

    expect(
      find.text('Some fields need attention before you can continue.'),
      findsOneWidget,
    );
  });

  testWidgets('feedback screen shows the empty state', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWith(
          (ref) => _FakeFeedbackRepository(
            items: const <Feedback>[],
            onSubmit:
                ({required type, rating, required message, metadata}) async =>
                    _feedback(id: 'f-1'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(
      tester,
      container: container,
      child: const FeedbackScreen(),
      wrapInScaffold: false,
    );

    expect(find.text('No feedback yet'), findsOneWidget);
    expect(
      find.textContaining('Your submitted feedback will appear here'),
      findsOneWidget,
    );
  });

  testWidgets('feedback screen shows the shared error state', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWith(
          (ref) => _FakeFeedbackRepository(
            items: const <Feedback>[],
            failList: true,
            onSubmit:
                ({required type, rating, required message, metadata}) async =>
                    _feedback(id: 'f-1'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(
      tester,
      container: container,
      child: const FeedbackScreen(),
      wrapInScaffold: false,
    );

    expect(find.text('Connection problem'), findsOneWidget);
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('feedback screen shows the status badge for each item', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWith(
          (ref) => _FakeFeedbackRepository(
            items: <Feedback>[
              _feedback(id: 'f-1').copyWith(status: FeedbackStatus.resolved),
            ],
            onSubmit:
                ({required type, rating, required message, metadata}) async =>
                    _feedback(id: 'f-1'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(
      tester,
      container: container,
      child: const FeedbackScreen(),
      wrapInScaffold: false,
    );

    expect(find.text('Resolved'), findsOneWidget);
  });
}
