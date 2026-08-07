import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/feedback/data/dto/feedback_json.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';

part 'feedback_response.freezed.dart';
part 'feedback_response.g.dart';

@freezed
abstract class FeedbackResponse with _$FeedbackResponse {
  const factory FeedbackResponse({
    required String id,
    required String userId,
    @JsonKey(fromJson: feedbackTypeFromJson, toJson: feedbackTypeToJson)
    required FeedbackType type,
    int? rating,
    required String message,
    Map<String, dynamic>? metadata,
    @JsonKey(fromJson: feedbackStatusFromJson, toJson: feedbackStatusToJson)
    required FeedbackStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FeedbackResponse;

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedbackResponseFromJson(json);
}

extension FeedbackResponseX on FeedbackResponse {
  Feedback toDomain() {
    return Feedback(
      id: id,
      userId: userId,
      type: type,
      rating: rating,
      message: message,
      metadata: metadata,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
