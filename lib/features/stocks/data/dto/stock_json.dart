num? stockNumOrNull(Object? value) {
  if (value is num) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return num.tryParse(value.replaceAll(',', ''));
  }
  return null;
}

num stockNum(Object? value) {
  return stockNumOrNull(value) ??
      (throw FormatException('Expected a valid number, got: $value'));
}

int? stockIntOrNull(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String && value.isNotEmpty) {
    return int.tryParse(value.replaceAll(',', ''));
  }
  return null;
}

int stockInt(Object? value) {
  return stockIntOrNull(value) ??
      (throw FormatException('Expected a valid integer, got: $value'));
}

DateTime? stockDateOrNull(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

DateTime stockDate(Object? value) {
  return stockDateOrNull(value) ??
      (throw FormatException('Expected a valid date, got: $value'));
}

DateTime stockDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  throw FormatException('Expected a valid date-time, got: $value');
}

String? stockStringOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString();
  return text.isEmpty ? null : text;
}

Map<String, String> stockStringMap(Object? value) {
  if (value is Map<Object?, Object?>) {
    return value.map(
      (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
    );
  }
  return const <String, String>{};
}
