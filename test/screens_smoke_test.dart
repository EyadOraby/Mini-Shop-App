import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makers_market/core/storage.dart';
import 'package:makers_market/main.dart';

/// Opens every screen of the app the way the web demo does (`?screen=`), in
/// English and Arabic, at phone and desktop widths, with the demo data, and
/// fails on any layout overflow or exception.
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

  const screens = ['shop', 'product&id=4', 'wishlist', 'cart', 'checkout', 'orders', 'admin'];

  for (final lang in ['en', 'ar']) {
    for (final size in [const Size(390, 844), const Size(820, 1180), const Size(1280, 800)]) {
      for (final screen in screens) {
        testWidgets('$screen renders ($lang, ${size.width.toInt()}px)', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.runAsync(() async {
            await tester.pumpWidget(MakersMarketApp(
              store: MemoryStore(),
              url: Uri.parse('https://x.test/?demo=1&lang=$lang&screen=$screen'),
            ));
            // Let the catalogue fall back to the bundled copy and the demo data load.
            await Future<void>.delayed(const Duration(milliseconds: 300));
          });
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 200));
          }

          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
