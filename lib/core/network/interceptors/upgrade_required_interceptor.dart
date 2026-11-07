import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Turns true once the API answers 426: this build is too old to talk to it.
class UpdateRequiredNotifier extends ValueNotifier<bool> {
  UpdateRequiredNotifier() : super(false);
}

class UpgradeRequiredInterceptor extends Interceptor {
  UpgradeRequiredInterceptor(this._notifier);

  final UpdateRequiredNotifier _notifier;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 426) _notifier.value = true;
    handler.next(err);
  }
}
