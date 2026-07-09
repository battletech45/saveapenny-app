import 'package:saveapenny/features/imports/domain/import_models.dart';

abstract interface class ImportsRepository {
  Future<ImportPreview> preview({required String filePath});
  Future<ImportStatus> confirm({required String importId});
  Future<ImportStatus> status({required String importId});
}
