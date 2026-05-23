enum LogLevel { debug, info, warning, error }

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  bool enableLogging = true;

  void debug(String message, {String? tag}) =>
      _log(LogLevel.debug, message, tag: tag);

  void info(String message, {String? tag}) =>
      _log(LogLevel.info, message, tag: tag);

  void warning(String message, {String? tag}) =>
      _log(LogLevel.warning, message, tag: tag);

  void error(String message, {Object? exception, String? tag}) {
    _log(LogLevel.error, message, tag: tag);
    if (exception != null) {
      _log(LogLevel.error, exception.toString(), tag: tag);
    }
  }

  void _log(LogLevel level, String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[$tag]' : '';
    final levelLabel = level.name.toUpperCase();
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    // ignore: avoid_print
    print('[$timestamp][$levelLabel]$prefix $message');
  }
}

final logger = LoggerService();
