import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/reports/domain/category_spending.dart';

part 'category_spending_response.freezed.dart';
part 'category_spending_response.g.dart';

@freezed
abstract class CategorySpendingResponse with _$CategorySpendingResponse {
  const factory CategorySpendingResponse({
    required String categoryId,
    required String categoryName,
    required num totalAmount,
    required num usagePercentage,
  }) = _CategorySpendingResponse;

  factory CategorySpendingResponse.fromJson(Map<String, dynamic> json) =>
      _$CategorySpendingResponseFromJson(json);
}

extension CategorySpendingResponseX on CategorySpendingResponse {
  CategorySpending toDomain() {
    return CategorySpending(
      categoryId: categoryId,
      categoryName: categoryName,
      totalAmount: totalAmount,
      usagePercentage: usagePercentage,
    );
  }
}
