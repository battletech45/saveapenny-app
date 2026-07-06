import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_goal_status_request.freezed.dart';
part 'update_goal_status_request.g.dart';

@freezed
abstract class UpdateGoalStatusRequest with _$UpdateGoalStatusRequest {
  const factory UpdateGoalStatusRequest({required String status}) =
      _UpdateGoalStatusRequest;

  factory UpdateGoalStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGoalStatusRequestFromJson(json);
}
