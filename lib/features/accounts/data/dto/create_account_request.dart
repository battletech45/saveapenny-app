import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_account_request.freezed.dart';
part 'create_account_request.g.dart';

@freezed
abstract class CreateAccountRequest with _$CreateAccountRequest {
  const factory CreateAccountRequest({
    required String name,
    required String type,
    required String currency,
    required num initialBalance,
  }) = _CreateAccountRequest;

  factory CreateAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAccountRequestFromJson(json);
}
