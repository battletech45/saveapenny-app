import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/imports/data/dto/import_preview_response.dart';
import 'package:saveapenny/features/imports/data/dto/import_status_response.dart';
import 'package:saveapenny/features/imports/data/imports_api.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';
import 'package:saveapenny/features/imports/domain/imports_repository.dart';

part 'imports_repository.g.dart';

class ImportsRepositoryImpl implements ImportsRepository {
  const ImportsRepositoryImpl(this._importsApi);

  final ImportsApi _importsApi;

  @override
  Future<ImportPreview> preview({required String filePath}) async {
    final response = await _importsApi.preview(filePath: filePath);
    return response.toDomain();
  }

  @override
  Future<ImportStatus> confirm({required String importId}) async {
    final response = await _importsApi.confirm(importId: importId);
    return response.toDomain();
  }

  @override
  Future<ImportStatus> status({required String importId}) async {
    final response = await _importsApi.status(importId: importId);
    return response.toDomain();
  }
}

@Riverpod(keepAlive: true)
ImportsRepository importsRepository(Ref ref) {
  return ImportsRepositoryImpl(ref.watch(importsApiProvider));
}
