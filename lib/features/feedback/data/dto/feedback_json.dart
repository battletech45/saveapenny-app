import 'package:saveapenny/features/feedback/domain/feedback.dart';

FeedbackType feedbackTypeFromJson(String value) {
  return switch (value.toUpperCase()) {
    'GENERAL' => FeedbackType.general,
    'FEATURE_REQUEST' => FeedbackType.featureRequest,
    'BUG_REPORT' => FeedbackType.bugReport,
    _ => throw FormatException('Unsupported feedback type: $value'),
  };
}

String feedbackTypeToJson(FeedbackType value) {
  return switch (value) {
    FeedbackType.general => 'GENERAL',
    FeedbackType.featureRequest => 'FEATURE_REQUEST',
    FeedbackType.bugReport => 'BUG_REPORT',
  };
}

FeedbackStatus feedbackStatusFromJson(String value) {
  return switch (value.toUpperCase()) {
    'OPEN' => FeedbackStatus.open,
    'IN_REVIEW' => FeedbackStatus.inReview,
    'RESOLVED' => FeedbackStatus.resolved,
    'REJECTED' => FeedbackStatus.rejected,
    _ => throw FormatException('Unsupported feedback status: $value'),
  };
}

String feedbackStatusToJson(FeedbackStatus value) {
  return switch (value) {
    FeedbackStatus.open => 'OPEN',
    FeedbackStatus.inReview => 'IN_REVIEW',
    FeedbackStatus.resolved => 'RESOLVED',
    FeedbackStatus.rejected => 'REJECTED',
  };
}
