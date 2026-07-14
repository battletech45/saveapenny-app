import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/ocr/data/dto/ocr_json.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';

part 'ocr_parse_diagnostics_response.freezed.dart';
part 'ocr_parse_diagnostics_response.g.dart';

@freezed
abstract class OcrParseDiagnosticsResponse with _$OcrParseDiagnosticsResponse {
  const factory OcrParseDiagnosticsResponse({
    String? detectedDocumentType,
    @JsonKey(fromJson: ocrDoubleOrNull) double? confidenceScore,
    @JsonKey(fromJson: ocrStringList)
    @Default(<String>[])
    List<String> warnings,
    @JsonKey(fromJson: ocrStringList) @Default(<String>[]) List<String> notes,
    String? selectedCandidateReason,
    String? noCandidateReason,
  }) = _OcrParseDiagnosticsResponse;

  factory OcrParseDiagnosticsResponse.fromJson(Map<String, dynamic> json) =>
      _$OcrParseDiagnosticsResponseFromJson(json);
}

extension OcrParseDiagnosticsResponseX on OcrParseDiagnosticsResponse {
  OcrParseDiagnostics toDomain() {
    return OcrParseDiagnostics(
      detectedDocumentType: detectedDocumentType,
      confidenceScore: confidenceScore,
      warnings: warnings,
      notes: notes,
      selectedCandidateReason: selectedCandidateReason,
      noCandidateReason: noCandidateReason,
    );
  }
}
