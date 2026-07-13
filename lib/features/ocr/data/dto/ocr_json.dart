import 'package:saveapenny/features/ocr/domain/ocr_models.dart';

OcrJobStatus ocrJobStatusFromJson(String raw) {
  return switch (raw) {
    'PENDING' => OcrJobStatus.pending,
    'RUNNING' => OcrJobStatus.running,
    'COMPLETED' => OcrJobStatus.completed,
    'FAILED' => OcrJobStatus.failed,
    _ => throw FormatException('Unsupported OCR job status: $raw'),
  };
}

DateTime ocrDateTime(Object? raw) {
  if (raw is String) {
    return DateTime.parse(raw);
  }

  throw FormatException('Unsupported date-time value: $raw');
}

DateTime ocrDateOrTime(Object? raw) {
  if (raw is String) {
    return DateTime.parse(raw);
  }

  throw FormatException('Unsupported date value: $raw');
}

DateTime? ocrDateOrTimeOrNull(Object? raw) {
  if (raw == null) {
    return null;
  }

  return ocrDateOrTime(raw);
}

double? ocrDoubleOrNull(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw);
  }

  return null;
}

num ocrNum(Object? raw) {
  if (raw is num) {
    return raw;
  }
  if (raw is String) {
    final parsed = num.tryParse(raw);
    if (parsed != null) {
      return parsed;
    }
  }

  throw FormatException('Unsupported numeric value: $raw');
}

num? ocrNumOrNull(Object? raw) {
  if (raw == null) {
    return null;
  }

  return ocrNum(raw);
}

List<String> ocrStringList(Object? raw) {
  if (raw is List<Object?>) {
    return raw.whereType<String>().toList(growable: false);
  }

  return const <String>[];
}

List<DateTime> ocrDateList(Object? raw) {
  if (raw is! List<Object?>) {
    return const <DateTime>[];
  }

  return raw.map(ocrDateOrTime).toList(growable: false);
}

List<num> ocrNumList(Object? raw) {
  if (raw is! List<Object?>) {
    return const <num>[];
  }

  return raw.map(ocrNum).toList(growable: false);
}

Map<String, dynamic> ocrReadJsonMap(Object? raw) {
  if (raw is Map<Object?, Object?>) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}
