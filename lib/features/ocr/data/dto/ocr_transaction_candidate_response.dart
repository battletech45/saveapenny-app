import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/ocr/data/dto/ocr_json.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';

part 'ocr_transaction_candidate_response.freezed.dart';
part 'ocr_transaction_candidate_response.g.dart';

@freezed
abstract class OcrTransactionCandidateResponse
    with _$OcrTransactionCandidateResponse {
  const factory OcrTransactionCandidateResponse({
    @JsonKey(fromJson: ocrDateOrTime) required DateTime date,
    @JsonKey(fromJson: ocrNum) required num amount,
    required String description,
    required String categoryHint,
  }) = _OcrTransactionCandidateResponse;

  factory OcrTransactionCandidateResponse.fromJson(Map<String, dynamic> json) =>
      _$OcrTransactionCandidateResponseFromJson(json);
}

extension OcrTransactionCandidateResponseX on OcrTransactionCandidateResponse {
  OcrTransactionCandidate toDomain() {
    return OcrTransactionCandidate(
      date: date,
      amount: amount,
      description: description,
      categoryHint: categoryHint,
    );
  }
}
