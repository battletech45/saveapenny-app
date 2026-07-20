import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/billing/revenuecat_session_sync.dart';
import 'package:saveapenny/core/push/push_notification_controller.dart';
import 'package:saveapenny/core/router/app_router.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    ref.listen(authSessionControllerProvider, (previous, next) {
      final sync = ref.read(revenueCatSessionSyncProvider.notifier);
      if (next == AuthStatus.authenticated) {
        unawaited(sync.onSessionRestored());
      } else if (next == AuthStatus.unauthenticated &&
          previous == AuthStatus.authenticated) {
        unawaited(sync.onLogout());
      }
    });

    if (ref.watch(authSessionControllerProvider) == AuthStatus.authenticated) {
      ref.watch(pushNotificationControllerProvider);
    }

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
