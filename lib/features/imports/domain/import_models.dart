enum ImportJobStatus { pending, running, completed, failed }

class ImportPreview {
  const ImportPreview({
    required this.importId,
    required this.fileName,
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
    required this.errors,
  });

  final String importId;
  final String fileName;
  final int totalRows;
  final int validRows;
  final int invalidRows;
  final List<ImportPreviewRowError> errors;
}

class ImportPreviewRowError {
  const ImportPreviewRowError({
    required this.rowNumber,
    required this.errorMessage,
    required this.rawData,
  });

  final int rowNumber;
  final String errorMessage;
  final String rawData;
}

class ImportStatus {
  const ImportStatus({
    required this.importId,
    required this.status,
    required this.totalRows,
    required this.importedRows,
    required this.failedRows,
    required this.createdAt,
    required this.updatedAt,
  });

  final String importId;
  final ImportJobStatus status;
  final int totalRows;
  final int importedRows;
  final int failedRows;
  final DateTime createdAt;
  final DateTime updatedAt;
}
