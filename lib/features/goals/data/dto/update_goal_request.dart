import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_goal_request.freezed.dart';
part 'update_goal_request.g.dart';

@freezed
abstract class UpdateGoalRequest with _$UpdateGoalRequest {
  const factory UpdateGoalRequest({
    String? title,
    num? targetAmount,
    String? currency,
    String? targetDate,
    String? linkedAccountId,
    Map<String, dynamic>? inputs,
  }) = _UpdateGoalRequest;

  factory UpdateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGoalRequestFromJson(json);
}
