import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/ocr/data/ocr_api.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/features/ocr/domain/ocr_repository.dart';

part 'ocr_repository.g.dart';

class OcrRepositoryImpl implements OcrRepository {
  const OcrRepositoryImpl(this._ocrApi);

  final OcrApi _ocrApi;

  @override
  Future<OcrSubmitJob> submit({required String filePath}) async {
    final response = await _ocrApi.submit(filePath: filePath);
    return OcrSubmitJob(jobId: response.jobId, status: response.status);
  }

  @override
  Future<OcrJob> status({required String jobId}) async {
    final response = await _ocrApi.status(jobId: jobId);
    return OcrJob(
      jobId: response.jobId,
      status: response.status,
      originalFileName: response.originalFileName,
      errorMessage: response.errorMessage,
      resultSnippet: response.resultSnippet,
      rawText: response.rawText,
      documentType: response.documentType,
      currency: response.currency,
      merchantName: response.merchantName,
      paymentDate: response.paymentDate,
      issueDate: response.issueDate,
      extractedDates: response.extractedDates,
      extractedAmounts: response.extractedAmounts,
      referenceNumbers: response.referenceNumbers,
      labels: response.labels,
      parseConfidence: response.parseConfidence,
      parseWarning: response.parseWarning,
      parseDiagnostics: response.parseDiagnostics == null
          ? null
          : OcrParseDiagnostics(
              detectedDocumentType:
                  response.parseDiagnostics!.detectedDocumentType,
              confidenceScore: response.parseDiagnostics!.confidenceScore,
              warnings: response.parseDiagnostics!.warnings,
              notes: response.parseDiagnostics!.notes,
              selectedCandidateReason:
                  response.parseDiagnostics!.selectedCandidateReason,
              noCandidateReason: response.parseDiagnostics!.noCandidateReason,
            ),
      transactionCandidates: response.transactionCandidates
          .map(
            (item) => OcrTransactionCandidate(
              date: item.date,
              amount: item.amount,
              description: item.description,
              categoryHint: item.categoryHint,
            ),
          )
          .toList(growable: false),
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
    );
  }
}

@Riverpod(keepAlive: true)
OcrRepository ocrRepository(Ref ref) {
  return OcrRepositoryImpl(ref.watch(ocrApiProvider));
}
