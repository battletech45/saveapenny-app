import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';

abstract interface class FeedbackRepository {
  Future<Feedback> submit({
    required FeedbackType type,
    int? rating,
    required String message,
    Map<String, dynamic>? metadata,
  });

  Future<PaginatedData<Feedback>> list({
    FeedbackType? type,
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  });

  Future<Feedback> getById(String feedbackId);

  Future<void> delete(String feedbackId);
}
