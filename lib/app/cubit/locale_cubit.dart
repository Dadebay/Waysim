import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../../core/storage/storage_keys.dart';
import '../../l10n/app_localizations.dart';

class LocaleCubit extends HydratedCubit<Locale> {
  LocaleCubit(this._storage) : super(defaultLocale);

  static const defaultLocale = Locale('en');

  final LocalStorage _storage;

  static List<Locale> get supported => AppLocalizations.supportedLocales;

  void setLocale(Locale locale) {
    if (supported.any((l) => l.languageCode == locale.languageCode)) {
      emit(Locale(locale.languageCode));
    }
  }

  @override
  void onChange(Change<Locale> change) {
    super.onChange(change);

    _storage.setString(
      StorageKeys.contentLanguage,
      change.nextState.languageCode,
    );
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final code = json['languageCode'] as String?;
    if (code == null || !supported.any((l) => l.languageCode == code)) {
      return null;
    }
    return Locale(code);
  }

  @override
  Map<String, dynamic>? toJson(Locale state) => {
    'languageCode': state.languageCode,
  };
}
