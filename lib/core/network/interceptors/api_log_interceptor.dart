import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';

class ApiLogInterceptor extends Interceptor {
  static const _maxBody = 1200;

  static const _maxLines = 30;

  static const _encoder = JsonEncoder.withIndent('  ');

  final _started = <RequestOptions, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _started[options] = DateTime.now();

    AppLogger.group(
      '${AnsiColor.paint('→ ${options.method}', AnsiColor.cyan)} '
      '${options.uri}',
      lines: [
        if (options.path.contains('/auth/')) _authHeaders(options.headers),
        ..._body(options.data),
      ],
    );

    handler.next(options);
  }

  String _authHeaders(Map<String, dynamic> headers) {
    String has(String name) => headers[name] == null ? 'missing' : 'sent';
    return 'headers: Accept-Language=${headers['Accept-Language'] ?? 'missing'} '
        'X-Device-Id=${has('X-Device-Id')} '
        'X-Firebase-AppCheck=${has('X-Firebase-AppCheck')} '
        'Authorization=${has('Authorization')} '
        'X-App-Version=${headers['X-App-Version'] ?? 'missing'}';
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final status = response.statusCode ?? 0;
    final colour = status >= 200 && status < 300
        ? AnsiColor.green
        : AnsiColor.yellow;

    AppLogger.group(
      '${AnsiColor.paint('← $status', colour)} '
      '${response.requestOptions.method} ${response.requestOptions.uri} '
      '${AnsiColor.paint(_elapsed(response.requestOptions), AnsiColor.grey)}',
      lines: _body(response.data),
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;

    AppLogger.group(
      '${AnsiColor.paint('← ${status ?? err.type.name}', AnsiColor.red)} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '${AnsiColor.paint(_elapsed(err.requestOptions), AnsiColor.grey)}',
      lines: _body(err.response?.data),
      level: Level.warning,
    );

    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final start = _started.remove(options);
    if (start == null) return '';
    return '${DateTime.now().difference(start).inMilliseconds}ms';
  }

  List<String> _body(dynamic body) {
    if (body == null) return const [];

    final text = _encode(_redact(body));
    if (text.trim().isEmpty) return const [];

    final truncated = text.length <= _maxBody
        ? text
        : '${text.substring(0, _maxBody)}… (${text.length} chars)';

    final lines = truncated.split('\n');
    if (lines.length <= _maxLines) return lines;
    return [
      ...lines.take(_maxLines),
      '… (${lines.length - _maxLines} more lines)',
    ];
  }

  dynamic _redact(dynamic value) {
    const sensitive = {
      'accessToken',
      'refreshToken',
      'deviceToken',
      'token',
      'code',
      'email',
      'activationCode',
      'lpaString',
      'qrCodeUrl',
      'appleUniversalLink',
      'smdpAddress',
      'iccid',
      'eid',
      'text',
      'payAddress',
      'payExtraId',
      'qrValue',
    };
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key,
          sensitive.contains(key) ? '[redacted]' : _redact(item),
        ),
      );
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }

  String _encode(dynamic body) {
    try {
      return _encoder.convert(body);
    } on Object {
      return body.toString();
    }
  }
}
