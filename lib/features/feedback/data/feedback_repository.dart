import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/feedback/data/dto/feedback_response.dart';
import 'package:saveapenny/features/feedback/data/dto/submit_feedback_request.dart';
import 'package:saveapenny/features/feedback/data/feedback_api.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';
import 'package:saveapenny/features/feedback/domain/feedback_repository.dart';

part 'feedback_repository.g.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  const FeedbackRepositoryImpl(this._feedbackApi);

  final FeedbackApi _feedbackApi;

  @override
  Future<Feedback> submit({
    required FeedbackType type,
    int? rating,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _feedbackApi.submit(
      SubmitFeedbackRequest(
        type: type,
        rating: rating,
        message: message,
        metadata: metadata,
      ),
    );
    return response.toDomain();
  }

  @override
  Future<PaginatedData<Feedback>> list({
    FeedbackType? type,
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    final response = await _feedbackApi.list(
      type: type,
      page: page,
      size: size,
      sort: sort,
    );

    return PaginatedData<Feedback>(
      items: response.items
          .map((FeedbackResponse item) => item.toDomain())
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
  Future<Feedback> getById(String feedbackId) async {
    final response = await _feedbackApi.getById(feedbackId);
    return response.toDomain();
  }

  @override
  Future<void> delete(String feedbackId) {
    return _feedbackApi.delete(feedbackId);
  }
}

@Riverpod(keepAlive: true)
FeedbackRepository feedbackRepository(Ref ref) {
  return FeedbackRepositoryImpl(ref.watch(feedbackApiProvider));
}
