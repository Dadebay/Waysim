import 'package:flutter/services.dart';

/// `flutter test` draws every glyph as a square (the Ahem test font) unless a
/// family is loaded by hand, which makes text far wider than it is on a
/// device and produces overflows that do not exist. Loading the real Gilroy
/// files gives layout tests honest metrics.
Future<void> loadAppFonts() async {
  final loader = FontLoader('Gilroy');
  for (final weight in const ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/Gilroy-$weight.ttf'));
  }
  await loader.load();
}
