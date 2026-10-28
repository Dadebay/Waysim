import 'package:flutter/services.dart';

Future<void> loadAppFonts() async {
  final loader = FontLoader('Gilroy');
  for (final weight in const ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/Gilroy-$weight.ttf'));
  }
  await loader.load();
}
