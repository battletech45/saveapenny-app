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
