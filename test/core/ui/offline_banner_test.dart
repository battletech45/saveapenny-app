import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/network/connectivity_service.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/ui/offline_banner.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

void main() {
  Future<void> pumpBanner(
    WidgetTester tester, {
    required AsyncValue<bool> isOnline,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith(
            (ref) => Stream.value(isOnline.value ?? true),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: OfflineBanner()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders nothing while online', (tester) async {
    await pumpBanner(tester, isOnline: const AsyncData(true));

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
  });

  testWidgets('shows the offline message when offline', (tester) async {
    await pumpBanner(tester, isOnline: const AsyncData(false));

    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.offlineBannerMessage), findsOneWidget);
  });
}
