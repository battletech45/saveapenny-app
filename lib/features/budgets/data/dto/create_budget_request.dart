import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_budget_request.freezed.dart';
part 'create_budget_request.g.dart';

@freezed
abstract class CreateBudgetRequest with _$CreateBudgetRequest {
  const factory CreateBudgetRequest({
    required String categoryId,
    required num amount,
    required String period,
    required String startDate,
    required String endDate,
  }) = _CreateBudgetRequest;

  factory CreateBudgetRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBudgetRequestFromJson(json);
}
