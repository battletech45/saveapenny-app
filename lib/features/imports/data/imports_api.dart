import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/imports/data/dto/confirm_import_request.dart';
import 'package:saveapenny/features/imports/data/dto/import_preview_response.dart';
import 'package:saveapenny/features/imports/data/dto/import_status_response.dart';

part 'imports_api.g.dart';

class ImportsApi {
  const ImportsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<ImportPreviewResponse> preview({required String filePath}) {
    return _apiClient.send<ImportPreviewResponse>(
      call: (dio) async {
        final formData = FormData.fromMap(<String, Object>{
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split(Platform.pathSeparator).last,
          ),
        });
        return dio.post<dynamic>(
          '/imports/transactions/preview',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      },
      fromData: (data) => ImportPreviewResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<ImportStatusResponse> confirm({required String importId}) {
    return _apiClient.send<ImportStatusResponse>(
      call: (dio) => dio.post<dynamic>(
        '/imports/transactions/confirm',
        data: ConfirmImportRequest(importId: importId).toJson(),
      ),
      fromData: (data) => ImportStatusResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<ImportStatusResponse> status({required String importId}) {
    return _apiClient.send<ImportStatusResponse>(
      call: (dio) => dio.get<dynamic>('/imports/transactions/$importId/status'),
      fromData: (data) => ImportStatusResponse.fromJson(_readJsonMap(data)),
    );
  }
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
ImportsApi importsApi(Ref ref) {
  return ImportsApi(ref.watch(apiClientProvider));
}
