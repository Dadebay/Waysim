import 'package:dio/dio.dart';

import '../../storage/local_storage.dart';
import '../../storage/storage_keys.dart';

class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._storage);

  static const supported = {'en', 'zh', 'ru', 'es', 'fr'};
  static const fallback = 'en';

  final LocalStorage _storage;

  static String resolve(String? languageCode) =>
      supported.contains(languageCode) ? languageCode! : fallback;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final stored = _storage.getString(StorageKeys.contentLanguage);
    options.headers['Accept-Language'] = resolve(stored);
    handler.next(options);
  }
}
