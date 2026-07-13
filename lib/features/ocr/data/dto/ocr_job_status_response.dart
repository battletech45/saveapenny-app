import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/ocr/data/dto/ocr_json.dart';
import 'package:saveapenny/features/ocr/data/dto/ocr_parse_diagnostics_response.dart';
import 'package:saveapenny/features/ocr/data/dto/ocr_transaction_candidate_response.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';

part 'ocr_job_status_response.freezed.dart';
part 'ocr_job_status_response.g.dart';

@freezed
abstract class OcrJobStatusResponse with _$OcrJobStatusResponse {
  const factory OcrJobStatusResponse({
    required String jobId,
    @JsonKey(fromJson: ocrJobStatusFromJson) required OcrJobStatus status,
    required String originalFileName,
    String? errorMessage,
    String? resultSnippet,
    String? rawText,
    String? documentType,
    String? currency,
    String? merchantName,
    @JsonKey(fromJson: ocrDateOrTimeOrNull) DateTime? paymentDate,
    @JsonKey(fromJson: ocrDateOrTimeOrNull) DateTime? issueDate,
    @JsonKey(fromJson: ocrDateList)
    @Default(<DateTime>[])
    List<DateTime> extractedDates,
    @JsonKey(fromJson: ocrNumList) @Default(<num>[]) List<num> extractedAmounts,
    @JsonKey(fromJson: ocrStringList)
    @Default(<String>[])
    List<String> referenceNumbers,
    @JsonKey(fromJson: ocrStringList) @Default(<String>[]) List<String> labels,
    @JsonKey(fromJson: ocrDoubleOrNull) double? parseConfidence,
    String? parseWarning,
    OcrParseDiagnosticsResponse? parseDiagnostics,
    @Default(<OcrTransactionCandidateResponse>[])
    List<OcrTransactionCandidateResponse> transactionCandidates,
    @JsonKey(fromJson: ocrDateTime) required DateTime createdAt,
    @JsonKey(fromJson: ocrDateTime) required DateTime updatedAt,
  }) = _OcrJobStatusResponse;

  factory OcrJobStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$OcrJobStatusResponseFromJson(json);
}

extension OcrJobStatusResponseX on OcrJobStatusResponse {
  OcrJob toDomain() {
    return OcrJob(
      jobId: jobId,
      status: status,
      originalFileName: originalFileName,
      errorMessage: errorMessage,
      resultSnippet: resultSnippet,
      rawText: rawText,
      documentType: documentType,
      currency: currency,
      merchantName: merchantName,
      paymentDate: paymentDate,
      issueDate: issueDate,
      extractedDates: extractedDates,
      extractedAmounts: extractedAmounts,
      referenceNumbers: referenceNumbers,
      labels: labels,
      parseConfidence: parseConfidence,
      parseWarning: parseWarning,
      parseDiagnostics: parseDiagnostics?.toDomain(),
      transactionCandidates: transactionCandidates
          .map((item) => item.toDomain())
          .toList(growable: false),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
