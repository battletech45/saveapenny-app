import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_goal_request.freezed.dart';
part 'create_goal_request.g.dart';

@freezed
abstract class CreateGoalRequest with _$CreateGoalRequest {
  const factory CreateGoalRequest({
    required String type,
    required String title,
    required num targetAmount,
    required String currency,
    required String targetDate,
    String? linkedAccountId,
    required Map<String, dynamic> inputs,
  }) = _CreateGoalRequest;

  factory CreateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGoalRequestFromJson(json);
}
