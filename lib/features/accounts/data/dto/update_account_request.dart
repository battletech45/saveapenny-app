import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_account_request.freezed.dart';
part 'update_account_request.g.dart';

@freezed
abstract class UpdateAccountRequest with _$UpdateAccountRequest {
  const factory UpdateAccountRequest({
    required String name,
    required String type,
    required String currency,
  }) = _UpdateAccountRequest;

  factory UpdateAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAccountRequestFromJson(json);
}
