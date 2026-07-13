import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/config/app_environment.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/ocr/data/dto/ocr_job_status_response.dart';
import 'package:saveapenny/features/ocr/data/dto/ocr_json.dart';
import 'package:saveapenny/features/ocr/data/dto/ocr_submit_response.dart';

part 'ocr_api.g.dart';

class OcrApi {
  const OcrApi(this._apiClient, this._environment);

  final ApiClient _apiClient;
  final AppEnvironment _environment;

  Future<OcrSubmitResponse> submit({required String filePath}) {
    return _apiClient.send<OcrSubmitResponse>(
      call: (dio) async {
        final formData = FormData.fromMap(<String, Object>{
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split(Platform.pathSeparator).last,
          ),
        });

        return dio.postUri(
          _uri('/api/imports/ocr'),
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      },
      fromData: (data) => OcrSubmitResponse.fromJson(ocrReadJsonMap(data)),
    );
  }

  Future<OcrJobStatusResponse> status({required String jobId}) {
    return _apiClient.send<OcrJobStatusResponse>(
      call: (dio) => dio.getUri(_uri('/api/imports/ocr/$jobId')),
      fromData: (data) => OcrJobStatusResponse.fromJson(ocrReadJsonMap(data)),
    );
  }

  Uri _uri(String path) {
    final baseUrl = _environment.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl$path');
  }
}

@Riverpod(keepAlive: true)
OcrApi ocrApi(Ref ref) {
  return OcrApi(
    ref.watch(apiClientProvider),
    ref.watch(appEnvironmentProvider),
  );
}
