import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/network/connectivity_service.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    required bool isOnline,
    required VoidCallback onPrimaryPressed,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWith((ref) => Stream.value(isOnline)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppSheetActionBar(
              primaryLabel: 'Save',
              onPrimaryPressed: onPrimaryPressed,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('primary button is enabled and no hint shows while online', (
    tester,
  ) async {
    var pressed = false;
    await pumpBar(
      tester,
      isOnline: true,
      onPrimaryPressed: () => pressed = true,
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);

    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isTrue);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.offlineActionDisabledMessage), findsNothing);
  });

  testWidgets('primary button is disabled and a hint shows while offline', (
    tester,
  ) async {
    var pressed = false;
    await pumpBar(
      tester,
      isOnline: false,
      onPrimaryPressed: () => pressed = true,
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    expect(pressed, isFalse);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.offlineActionDisabledMessage), findsOneWidget);
  });
}
