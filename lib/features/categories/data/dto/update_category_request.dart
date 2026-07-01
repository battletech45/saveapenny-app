import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_category_request.freezed.dart';
part 'update_category_request.g.dart';

@freezed
abstract class UpdateCategoryRequest with _$UpdateCategoryRequest {
  const factory UpdateCategoryRequest({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) = _UpdateCategoryRequest;

  factory UpdateCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCategoryRequestFromJson(json);
}
