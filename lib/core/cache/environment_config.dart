import 'package:logger/logger.dart';

class EnvironmentConfig {
  final bool shouldCollectCrashLog;
  late final Logger logger;
  EnvironmentConfig({
    // required this.appName,
    this.shouldCollectCrashLog = false,
  }) {
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: AppValues.loggerMethodCount,
        // number of method calls to be displayed
        errorMethodCount: AppValues.loggerErrorMethodCount,
        // number of method calls if stacktrace is provided
        lineLength: AppValues.loggerLineLength,
        // width of the output
        colors: true,
        // Colorful log messages
        printEmojis: true,
      ),
    );
  }
}

abstract class AppValues {
  static const int loggerLineLength = 120;
  static const int loggerErrorMethodCount = 8;
  static const int loggerMethodCount = 2;
}