import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback.freezed.dart';

enum FeedbackType { general, featureRequest, bugReport }

enum FeedbackStatus { open, inReview, resolved, rejected }

@freezed
abstract class Feedback with _$Feedback {
  const factory Feedback({
    required String id,
    required String userId,
    required FeedbackType type,
    int? rating,
    required String message,
    Map<String, dynamic>? metadata,
    required FeedbackStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Feedback;
}
