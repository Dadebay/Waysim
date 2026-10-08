import 'dart:ui';

/// The five app languages, in the order the language picker lists them.
///
/// [nativeName] is shown in its own script and is never translated, so a
/// person who landed in the wrong language can still find theirs.
/// [flagCode] names a file in `assets/flags/`.
enum AppLanguage {
  en('English', 'gb'),
  zh('中文', 'cn'),
  ru('Русский', 'ru'),
  es('Español', 'es'),
  fr('Français', 'fr');

  const AppLanguage(this.nativeName, this.flagCode);

  final String nativeName;
  final String flagCode;

  String get code => name;
  Locale get locale => Locale(name);

  static AppLanguage fromLocale(Locale locale) => values.firstWhere(
    (l) => l.code == locale.languageCode,
    orElse: () => AppLanguage.en,
  );
}
