import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_settings_store.g.dart';

enum AppLocaleSetting { system, english, turkish }

enum AppThemeSetting { system, light, dark }

class AppSettings {
  const AppSettings({
    this.locale = AppLocaleSetting.system,
    this.theme = AppThemeSetting.system,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      locale: _parseLocaleSetting(json['locale'] as String?),
      theme: _parseThemeSetting(json['theme'] as String?),
    );
  }

  final AppLocaleSetting locale;
  final AppThemeSetting theme;

  Locale? get resolvedLocale => switch (locale) {
    AppLocaleSetting.system => null,
    AppLocaleSetting.english => const Locale('en'),
    AppLocaleSetting.turkish => const Locale('tr'),
  };

  ThemeMode get resolvedThemeMode => switch (theme) {
    AppThemeSetting.system => ThemeMode.system,
    AppThemeSetting.light => ThemeMode.light,
    AppThemeSetting.dark => ThemeMode.dark,
  };

  AppSettings copyWith({AppLocaleSetting? locale, AppThemeSetting? theme}) {
    return AppSettings(
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'locale': locale.name, 'theme': theme.name};
  }
}

class AppSettingsStore {
  static const String _fileName = 'app_settings.json';

  Future<AppSettings> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        return const AppSettings();
      }

      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const AppSettings();
      }

      return AppSettings.fromJson(decoded);
    } on FileSystemException {
      return const AppSettings();
    } on FormatException {
      return const AppSettings();
    }
  }

  Future<void> write(AppSettings settings) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(settings.toJson()));
  }

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }
}

@Riverpod(keepAlive: true)
AppSettingsStore appSettingsStore(Ref ref) {
  return AppSettingsStore();
}

AppLocaleSetting _parseLocaleSetting(String? value) {
  for (final setting in AppLocaleSetting.values) {
    if (setting.name == value) {
      return setting;
    }
  }

  return AppLocaleSetting.system;
}

AppThemeSetting _parseThemeSetting(String? value) {
  for (final setting in AppThemeSetting.values) {
    if (setting.name == value) {
      return setting;
    }
  }

  return AppThemeSetting.system;
}
