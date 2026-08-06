import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/app_settings_store.dart';

part 'app_settings_controller.g.dart';

@Riverpod(keepAlive: true)
class AppSettingsController extends _$AppSettingsController {
  @override
  AppSettings build() {
    unawaited(_initialize());
    return const AppSettings();
  }

  Future<void> setLocale(AppLocaleSetting locale) async {
    final next = state.copyWith(locale: locale);
    state = next;
    await ref.read(appSettingsStoreProvider).write(next);
  }

  Future<void> setTheme(AppThemeSetting theme) async {
    final next = state.copyWith(theme: theme);
    state = next;
    await ref.read(appSettingsStoreProvider).write(next);
  }

  Future<void> _initialize() async {
    state = await ref.read(appSettingsStoreProvider).read();
  }
}
