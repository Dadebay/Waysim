import 'package:logger/logger.dart';

import '../constants/app_environment.dart';

/// So a call site can pick a level for [AppLogger.group] without importing
/// the logger package itself — which would drag in its own `AnsiColor` and
/// clash with the one below.
export 'package:logger/logger.dart' show Level;

/// App-wide logger. Silent in production builds.
///
/// A plain log is one line: a coloured level tag, the time, then the message.
/// `PrettyPrinter`'s boxes are deliberately gone — they turn a three-word log
/// into six lines of box drawing, which is what made the debug console
/// unreadable once the network layer started talking.
///
/// Anything with a body — a request, a response, a bloc transition — goes
/// through [group] instead: a rule, a headline, then the body indented under
/// it. One rule per block is what separates entries in a console that
/// interleaves them with platform noise; a border around each line is not.
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

  /// A block: [title] on the tag line, [lines] indented beneath it, the whole
  /// thing fenced off from whatever the console printed before it.
  static void group(
    String title, {
    List<String> lines = const [],
    Level level = Level.debug,
  }) => _logger.log(level, LogGroup(title, lines: lines));
}

/// Message type [AppLogger.group] hands the printer. Carried as the message
/// rather than pre-formatted text so the printer stays the only place that
/// knows what a block looks like.
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

/// ANSI escapes. Both VS Code's debug console and Android Studio's render
/// these, so a warning actually looks like a warning instead of blending
/// into the wall of platform noise around it.
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

  /// Wraps [text] in [color], and always closes it — an unterminated escape
  /// bleeds into every line the console prints afterwards.
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

  /// Wide enough for a URL with its timing, short enough to survive the
  /// narrow console pane most of this is read in.
  static final _rule = '─' * 72;

  /// `DEBUG 12:34:56 ` — body lines start where the message does.
  static const _indent = '               ';

  @override
  List<String> log(LogEvent event) {
    final (label, color) = _tags[event.level] ?? ('  LOG', AnsiColor.grey);
    final time = event.time.toIso8601String().substring(11, 19);
    final message = event.message;

    final headline = message is LogGroup ? message.title : '$message';
    final lines = <String>[
      if (message is LogGroup) AnsiColor.paint(_rule, AnsiColor.dim),
      '${AnsiColor.paint('$color${AnsiColor.bold}$label', color)} '
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
      // Deep traces are mostly framework frames; the first few are the ones
      // that say where this actually went wrong.
      for (final line in trace.toString().split('\n').take(8)) {
        if (line.trim().isEmpty) continue;
        lines.add(AnsiColor.paint('        $line', AnsiColor.dim));
      }
    }

    return lines;
  }
}
