import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/feedback/data/dto/feedback_json.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';

part 'submit_feedback_request.freezed.dart';
part 'submit_feedback_request.g.dart';

@freezed
abstract class SubmitFeedbackRequest with _$SubmitFeedbackRequest {
  const factory SubmitFeedbackRequest({
    @JsonKey(fromJson: feedbackTypeFromJson, toJson: feedbackTypeToJson)
    required FeedbackType type,
    int? rating,
    required String message,
    Map<String, dynamic>? metadata,
  }) = _SubmitFeedbackRequest;

  factory SubmitFeedbackRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitFeedbackRequestFromJson(json);
}
