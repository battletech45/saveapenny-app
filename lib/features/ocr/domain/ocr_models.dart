import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_models.freezed.dart';

enum OcrJobStatus { pending, running, completed, failed }

@freezed
abstract class OcrSubmitJob with _$OcrSubmitJob {
  const factory OcrSubmitJob({
    required String jobId,
    required OcrJobStatus status,
  }) = _OcrSubmitJob;
}

@freezed
abstract class OcrTransactionCandidate with _$OcrTransactionCandidate {
  const factory OcrTransactionCandidate({
    required DateTime date,
    required num amount,
    required String description,
    required String categoryHint,
  }) = _OcrTransactionCandidate;
}

@freezed
abstract class OcrParseDiagnostics with _$OcrParseDiagnostics {
  const factory OcrParseDiagnostics({
    String? detectedDocumentType,
    double? confidenceScore,
    @Default(<String>[]) List<String> warnings,
    @Default(<String>[]) List<String> notes,
    String? selectedCandidateReason,
    String? noCandidateReason,
  }) = _OcrParseDiagnostics;
}

@freezed
abstract class OcrJob with _$OcrJob {
  const factory OcrJob({
    required String jobId,
    required OcrJobStatus status,
    required String originalFileName,
    String? errorMessage,
    String? resultSnippet,
    String? rawText,
    String? documentType,
    String? currency,
    String? merchantName,
    DateTime? paymentDate,
    DateTime? issueDate,
    @Default(<DateTime>[]) List<DateTime> extractedDates,
    @Default(<num>[]) List<num> extractedAmounts,
    @Default(<String>[]) List<String> referenceNumbers,
    @Default(<String>[]) List<String> labels,
    double? parseConfidence,
    String? parseWarning,
    OcrParseDiagnostics? parseDiagnostics,
    @Default(<OcrTransactionCandidate>[])
    List<OcrTransactionCandidate> transactionCandidates,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OcrJob;
}
