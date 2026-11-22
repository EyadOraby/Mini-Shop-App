import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makers_market/core/storage.dart';
import 'package:makers_market/main.dart';
import 'package:material_ui/material_ui.dart';

/// Opens the app on one screen with the demo data, as the web demo does.
Future<void> open(WidgetTester tester, String screen, {Size size = const Size(1280, 1800)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.runAsync(() async {
    await tester.pumpWidget(MakersMarketApp(
      store: MemoryStore(),
      url: Uri.parse('https://x.test/?demo=1&lang=en&screen=$screen'),
    ));
    // Let the catalogue fall back to the bundled copy and the demo data load.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUpAll(() async {
    Future<ByteData> load(String path) => File(path).readAsBytes().then((b) => ByteData.sublistView(b));
    for (final (family, file) in [
      ('WorkSans', 'WorkSans.ttf'),
      ('Fraunces', 'Fraunces.ttf'),
      ('ReadexPro', 'ReadexPro.ttf'),
      ('Amiri', 'Amiri-Bold.ttf'),
    ]) {
      await (FontLoader(family)..addFont(load('assets/fonts/$file'))).load();
    }
  });

  testWidgets('checkout asks for the details, then places the order', (tester) async {
    await open(tester, 'checkout');

    final place = find.textContaining('Place order');
    expect(place, findsOneWidget);
    await tester.tap(place);
    await tester.pump();
    expect(find.text('Please enter your phone number'), findsOneWidget);
    expect(find.textContaining('Order placed!'), findsNothing);

    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Mona Adel');
    await tester.enterText(find.widgetWithText(TextFormField, 'Street address'), '12 Tahrir St');
    await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'Cairo');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '12');
    await tester.tap(place);
    await tester.pump();
    expect(find.text('Enter a valid phone number'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '+20 100 123 4567');
    await tester.tap(place);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Order placed!'), findsOneWidget);
    expect(find.text('Continue shopping'), findsOneWidget);
  });

  testWidgets('the owner dashboard moves between sections and resets its data', (tester) async {
    await open(tester, 'admin', size: const Size(390, 1000));

    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Products')));
    await tester.pumpAndSettle();
    expect(find.text('Category'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Orders')));
    await tester.pumpAndSettle();
    expect(find.text('Customer'), findsOneWidget);

    await tester.tap(find.byTooltip('Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear all orders'));
    await tester.pumpAndSettle();
    expect(find.text('No sales yet'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add sample orders'));
    await tester.pumpAndSettle();
    expect(find.text('No sales yet'), findsNothing);
    expect(find.text('Customer'), findsOneWidget);
  });
}
