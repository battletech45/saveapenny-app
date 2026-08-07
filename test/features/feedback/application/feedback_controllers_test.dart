import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/feedback/application/feedback_list_controller.dart';
import 'package:saveapenny/features/feedback/application/submit_feedback_controller.dart';
import 'package:saveapenny/features/feedback/data/feedback_metadata_builder.dart';
import 'package:saveapenny/features/feedback/data/feedback_repository.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';
import 'package:saveapenny/features/feedback/domain/feedback_repository.dart';

class _FakeFeedbackRepository implements FeedbackRepository {
  _FakeFeedbackRepository({
    this.onSubmit,
    this.onList,
    this.onGetById,
    this.onDelete,
  });

  final Future<Feedback> Function({
    required FeedbackType type,
    int? rating,
    required String message,
    Map<String, dynamic>? metadata,
  })?
  onSubmit;
  final Future<PaginatedData<Feedback>> Function({
    FeedbackType? type,
    required int page,
    required int size,
    required String sort,
  })?
  onList;
  final Future<Feedback> Function(String feedbackId)? onGetById;
  final Future<void> Function(String feedbackId)? onDelete;

  @override
  Future<void> delete(String feedbackId) {
    return onDelete!(feedbackId);
  }

  @override
  Future<Feedback> getById(String feedbackId) {
    return onGetById!(feedbackId);
  }

  @override
  Future<PaginatedData<Feedback>> list({
    FeedbackType? type,
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) {
    return onList!(type: type, page: page, size: size, sort: sort);
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
  const _FakeFeedbackMetadataBuilder(this.metadata);

  final Map<String, dynamic> metadata;

  @override
  Future<Map<String, dynamic>> build({required String screen}) async {
    return <String, dynamic>{...metadata, 'screen': screen};
  }
}

Feedback _feedback({
  required String id,
  FeedbackType type = FeedbackType.general,
}) {
  return Feedback(
    id: id,
    userId: 'u-1',
    type: type,
    rating: 4,
    message: 'Useful app.',
    metadata: const <String, dynamic>{'screen': 'profile'},
    status: FeedbackStatus.open,
    createdAt: DateTime.parse('2026-07-31T10:00:00Z'),
    updatedAt: DateTime.parse('2026-07-31T10:00:00Z'),
  );
}

PaginatedData<Feedback> _page(
  List<Feedback> items, {
  int page = 0,
  bool hasNext = false,
  bool hasPrevious = false,
}) {
  return PaginatedData<Feedback>(
    items: items,
    page: page,
    size: 20,
    totalItems: items.length,
    totalPages: hasNext ? page + 2 : page + 1,
    hasNext: hasNext,
    hasPrevious: hasPrevious,
  );
}

void main() {
  test('feedback list controller builds the first page', () async {
    final item = _feedback(id: 'f-1');

    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWith(
          (ref) => _FakeFeedbackRepository(
            onList:
                ({type, required page, required size, required sort}) async =>
                    _page(<Feedback>[item]),
            onSubmit:
                ({required type, rating, required message, metadata}) async =>
                    item,
            onGetById: (feedbackId) async => item,
            onDelete: (_) async {},
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(feedbackListControllerProvider.future);

    expect(state.items, hasLength(1));
    expect(state.items.single, item);
    expect(state.typeFilter, isNull);
  });

  test('feedback list controller preserves state when delete fails', () async {
    final item = _feedback(id: 'f-1');

    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWith(
          (ref) => _FakeFeedbackRepository(
            onList:
                ({type, required page, required size, required sort}) async =>
                    _page(<Feedback>[item]),
            onSubmit:
                ({required type, rating, required message, metadata}) async =>
                    item,
            onGetById: (feedbackId) async => item,
            onDelete: (_) async {
              throw const Failure.api(
                code: ApiErrorCode.feedbackNotFound,
                message: 'Feedback not found.',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(feedbackListControllerProvider.future);

    await expectLater(
      container
          .read(feedbackListControllerProvider.notifier)
          .deleteFeedback('f-1'),
      throwsA(isA<ApiFailure>()),
    );

    expect(
      container.read(feedbackListControllerProvider).value?.items.single,
      item,
    );
  });

  test('submit feedback controller exposes api failures', () async {
    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWith(
          (ref) => _FakeFeedbackRepository(
            onList:
                ({type, required page, required size, required sort}) async =>
                    _page(const <Feedback>[]),
            onSubmit:
                ({required type, rating, required message, metadata}) async {
                  throw const Failure.api(
                    code: ApiErrorCode.validationFailed,
                    message: 'Validation failed.',
                  );
                },
            onGetById: (_) async => _feedback(id: 'f-1'),
            onDelete: (_) async {},
          ),
        ),
        feedbackMetadataBuilderProvider.overrideWith(
          (ref) => const _FakeFeedbackMetadataBuilder(<String, dynamic>{
            'platform': 'ios',
            'appVersion': '1.0.0',
          }),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(submitFeedbackControllerProvider.notifier)
        .submit(
          type: FeedbackType.general,
          message: 'Bad validation payload',
          screen: 'profile',
        );

    expect(container.read(submitFeedbackControllerProvider).hasError, isTrue);
    expect(
      container.read(submitFeedbackControllerProvider).error,
      isA<ApiFailure>().having(
        (failure) => failure.code,
        'code',
        ApiErrorCode.validationFailed,
      ),
    );
  });
}
