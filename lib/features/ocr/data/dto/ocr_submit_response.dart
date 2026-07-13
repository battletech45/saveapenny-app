import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/ocr/data/dto/ocr_json.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';

part 'ocr_submit_response.freezed.dart';
part 'ocr_submit_response.g.dart';

@freezed
abstract class OcrSubmitResponse with _$OcrSubmitResponse {
  const factory OcrSubmitResponse({
    required String jobId,
    @JsonKey(fromJson: ocrJobStatusFromJson) required OcrJobStatus status,
  }) = _OcrSubmitResponse;

  factory OcrSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$OcrSubmitResponseFromJson(json);
}

extension OcrSubmitResponseX on OcrSubmitResponse {
  OcrSubmitJob toDomain() {
    return OcrSubmitJob(jobId: jobId, status: status);
  }
}
