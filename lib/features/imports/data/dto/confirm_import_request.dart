import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_import_request.freezed.dart';
part 'confirm_import_request.g.dart';

@freezed
abstract class ConfirmImportRequest with _$ConfirmImportRequest {
  const factory ConfirmImportRequest({required String importId}) =
      _ConfirmImportRequest;

  factory ConfirmImportRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfirmImportRequestFromJson(json);
}
