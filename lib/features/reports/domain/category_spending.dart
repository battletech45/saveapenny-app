import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_spending.freezed.dart';

@freezed
abstract class CategorySpending with _$CategorySpending {
  const factory CategorySpending({
    required String categoryId,
    required String categoryName,
    required num totalAmount,
    required num usagePercentage,
  }) = _CategorySpending;
}
