import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_budget_request.freezed.dart';
part 'update_budget_request.g.dart';

@freezed
abstract class UpdateBudgetRequest with _$UpdateBudgetRequest {
  const factory UpdateBudgetRequest({
    required String categoryId,
    required num amount,
    required String period,
    required String startDate,
    required String endDate,
  }) = _UpdateBudgetRequest;

  factory UpdateBudgetRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBudgetRequestFromJson(json);
}
