import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/app.dart';

void main() {
  testWidgets('phase 0 app boots to the placeholder home shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
  });

  testWidgets('phase 0 shell localizes and previews shared async states', (
    WidgetTester tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('tr');
    tester.binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('tr'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Eszamansiz durum onizlemesi'), findsOneWidget);

    await tester.tap(find.text('Yukleniyor'));
    await tester.pump();
    expect(find.text('Yukleniyor...'), findsOneWidget);

    await tester.tap(find.text('Hata'));
    await tester.pump();
    expect(find.text('Baglanti sorunu'), findsOneWidget);
  });
}
