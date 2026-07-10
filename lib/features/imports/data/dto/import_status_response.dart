import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/imports/domain/import_models.dart';

part 'import_status_response.freezed.dart';
part 'import_status_response.g.dart';

@freezed
abstract class ImportStatusResponse with _$ImportStatusResponse {
  const factory ImportStatusResponse({
    required String importId,
    required String status,
    required int totalRows,
    required int importedRows,
    required int failedRows,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ImportStatusResponse;

  factory ImportStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ImportStatusResponseFromJson(json);
}

extension ImportStatusResponseX on ImportStatusResponse {
  ImportStatus toDomain() {
    return ImportStatus(
      importId: importId,
      status: _statusFromWire(status),
      totalRows: totalRows,
      importedRows: importedRows,
      failedRows: failedRows,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

ImportJobStatus _statusFromWire(String value) {
  return switch (value) {
    'PENDING' => ImportJobStatus.pending,
    'RUNNING' => ImportJobStatus.running,
    'COMPLETED' => ImportJobStatus.completed,
    'FAILED' => ImportJobStatus.failed,
    _ => throw FormatException('Unsupported import status: $value'),
  };
}
