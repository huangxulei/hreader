import 'dart:io';

import 'get_base_path.dart';

Future<File> getLogFile() async {
  final logFileDir = await getHDocmentsPath();
  final String logFilePath = '$logFileDir${Platform.pathSeparator}h_reader.log';
  final logFile = File(logFilePath);
  if (!logFile.existsSync()) {
    logFile.createSync();
  }
  return logFile;
}
