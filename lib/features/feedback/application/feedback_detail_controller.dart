import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/feedback/application/feedback_list_controller.dart';
import 'package:saveapenny/features/feedback/data/feedback_repository.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';

part 'feedback_detail_controller.g.dart';

@riverpod
class FeedbackDetailController extends _$FeedbackDetailController {
  @override
  Future<Feedback> build(String feedbackId) {
    return ref.read(feedbackRepositoryProvider).getById(feedbackId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(feedbackRepositoryProvider).getById(feedbackId),
    );
  }

  Future<void> delete() async {
    final current = state is AsyncData<Feedback>
        ? (state as AsyncData<Feedback>).value
        : null;

    try {
      await ref.read(feedbackRepositoryProvider).delete(feedbackId);
      await ref.read(feedbackListControllerProvider.notifier).refresh();
    } on Failure catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(error, stackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } on Object catch (error, stackTrace) {
      final failure = Failure.unknown(message: error.toString());
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(failure, stackTrace);
      }
      Error.throwWithStackTrace(failure, stackTrace);
    }
  }
}
