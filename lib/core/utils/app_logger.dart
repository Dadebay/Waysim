import 'package:logger/logger.dart';

import '../constants/app_environment.dart';

export 'package:logger/logger.dart' show Level;

abstract final class AppLogger {
  static final Logger _logger = Logger(
    filter: _EnvFilter(),
    printer: _ConsolePrinter(),
  );

  static void d(Object? message) => _logger.d(message);
  static void i(Object? message) => _logger.i(message);
  static void w(Object? message) => _logger.w(message);
  static void e(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  static void group(
    String title, {
    List<String> lines = const [],
    Level level = Level.debug,
  }) => _logger.log(level, LogGroup(title, lines: lines));
}

class LogGroup {
  const LogGroup(this.title, {this.lines = const []});

  final String title;
  final List<String> lines;

  @override
  String toString() => [title, ...lines].join('\n');
}

class _EnvFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => AppEnvironment.enableLogging;
}

abstract final class AnsiColor {
  static const reset = '\x1B[0m';
  static const bold = '\x1B[1m';
  static const dim = '\x1B[2m';

  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const blue = '\x1B[34m';
  static const magenta = '\x1B[35m';
  static const cyan = '\x1B[36m';
  static const grey = '\x1B[90m';

  static String paint(String text, String color) => '$color$text$reset';
}

class _ConsolePrinter extends LogPrinter {
  static const _tags = {
    Level.trace: ('TRACE', AnsiColor.grey),
    Level.debug: ('DEBUG', AnsiColor.cyan),
    Level.info: (' INFO', AnsiColor.green),
    Level.warning: (' WARN', AnsiColor.yellow),
    Level.error: ('ERROR', AnsiColor.red),
    Level.fatal: ('FATAL', AnsiColor.magenta),
  };

  static final _rule = '─' * 72;

  static const _indent = '               ';

  @override
  List<String> log(LogEvent event) {
    final (label, color) = _tags[event.level] ?? ('  LOG', AnsiColor.grey);
    final time = event.time.toIso8601String().substring(11, 19);
    final message = event.message;

    final headline = message is LogGroup ? message.title : '$message';
    final lines = <String>[
      if (message is LogGroup) AnsiColor.paint(_rule, AnsiColor.dim),
      '${AnsiColor.paint('${AnsiColor.bold}$label', color)} '
          '${AnsiColor.paint(time, AnsiColor.grey)} '
          '${AnsiColor.paint(headline, color)}',
      if (message is LogGroup)
        for (final line in message.lines)
          AnsiColor.paint('$_indent$line', AnsiColor.grey),
    ];

    final error = event.error;
    if (error != null) {
      lines.add(AnsiColor.paint('        $error', AnsiColor.red));
    }

    final trace = event.stackTrace;
    if (trace != null) {
      for (final line in trace.toString().split('\n').take(8)) {
        if (line.trim().isEmpty) continue;
        lines.add(AnsiColor.paint('        $line', AnsiColor.dim));
      }
    }

    return lines;
  }
}
