import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/imports/domain/import_models.dart';

part 'import_preview_response.freezed.dart';
part 'import_preview_response.g.dart';

@freezed
abstract class ImportPreviewResponse with _$ImportPreviewResponse {
  const factory ImportPreviewResponse({
    required String importId,
    required String fileName,
    required int totalRows,
    required int validRows,
    required int invalidRows,
    required List<ImportPreviewRowErrorResponse> errors,
  }) = _ImportPreviewResponse;

  factory ImportPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$ImportPreviewResponseFromJson(json);
}

extension ImportPreviewResponseX on ImportPreviewResponse {
  ImportPreview toDomain() {
    return ImportPreview(
      importId: importId,
      fileName: fileName,
      totalRows: totalRows,
      validRows: validRows,
      invalidRows: invalidRows,
      errors: errors.map((e) => e.toDomain()).toList(growable: false),
    );
  }
}

@freezed
abstract class ImportPreviewRowErrorResponse
    with _$ImportPreviewRowErrorResponse {
  const factory ImportPreviewRowErrorResponse({
    required int rowNumber,
    required String errorMessage,
    required String rawData,
  }) = _ImportPreviewRowErrorResponse;

  factory ImportPreviewRowErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ImportPreviewRowErrorResponseFromJson(json);
}

extension ImportPreviewRowErrorResponseX on ImportPreviewRowErrorResponse {
  ImportPreviewRowError toDomain() {
    return ImportPreviewRowError(
      rowNumber: rowNumber,
      errorMessage: errorMessage,
      rawData: rawData,
    );
  }
}
