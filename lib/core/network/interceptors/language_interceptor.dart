import 'package:dio/dio.dart';

import '../../storage/local_storage.dart';
import '../../storage/storage_keys.dart';

/// Sends `Accept-Language` on every request.
///
/// The header picks the language of country names, package descriptions, push
/// text and e-mails the server produces. The app supports five languages;
/// anything else falls back to English.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._storage);

  static const supported = {'en', 'zh', 'ru', 'es', 'fr'};
  static const fallback = 'en';

  final LocalStorage _storage;

  /// Maps an app locale to a language the API understands.
  static String resolve(String? languageCode) =>
      supported.contains(languageCode) ? languageCode! : fallback;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final stored = _storage.getString(StorageKeys.contentLanguage);
    options.headers['Accept-Language'] = resolve(stored);
    handler.next(options);
  }
}
