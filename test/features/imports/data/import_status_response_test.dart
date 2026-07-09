import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/features/imports/data/dto/import_status_response.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';

void main() {
  test('toDomain maps supported wire import statuses', () {
    final response = ImportStatusResponse(
      importId: 'imp-1',
      status: 'RUNNING',
      totalRows: 10,
      importedRows: 4,
      failedRows: 0,
      createdAt: DateTime.parse('2026-06-09T00:00:00Z'),
      updatedAt: DateTime.parse('2026-06-09T00:05:00Z'),
    );

    final status = response.toDomain();

    expect(status.status, ImportJobStatus.running);
  });

  test('toDomain rejects unsupported wire import statuses', () {
    final response = ImportStatusResponse(
      importId: 'imp-1',
      status: 'CANCELLED',
      totalRows: 10,
      importedRows: 4,
      failedRows: 0,
      createdAt: DateTime.parse('2026-06-09T00:00:00Z'),
      updatedAt: DateTime.parse('2026-06-09T00:05:00Z'),
    );

    expect(response.toDomain, throwsFormatException);
  });
}
