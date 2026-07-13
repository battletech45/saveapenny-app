import 'package:saveapenny/features/ocr/domain/ocr_models.dart';

abstract interface class OcrRepository {
  Future<OcrSubmitJob> submit({required String filePath});

  Future<OcrJob> status({required String jobId});
}
