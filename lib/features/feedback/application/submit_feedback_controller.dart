import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/feedback/application/feedback_list_controller.dart';
import 'package:saveapenny/features/feedback/data/feedback_metadata_builder.dart';
import 'package:saveapenny/features/feedback/data/feedback_repository.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';

part 'submit_feedback_controller.g.dart';

@riverpod
class SubmitFeedbackController extends _$SubmitFeedbackController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> submit({
    required FeedbackType type,
    int? rating,
    required String message,
    required String screen,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final metadata = await ref
          .read(feedbackMetadataBuilderProvider)
          .build(screen: screen);

      await ref
          .read(feedbackRepositoryProvider)
          .submit(
            type: type,
            rating: rating,
            message: message,
            metadata: metadata,
          );

      ref.invalidate(feedbackListControllerProvider);
    });
  }
}
