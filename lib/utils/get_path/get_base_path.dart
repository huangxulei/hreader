import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

String documentPath = '';
//C:\Users\magic\AppData\Roaming\com.anxcye\anx_reader
Future<String> getHDocmentsPath() async {
  final directory = await getApplicationDocumentsDirectory();

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return directory.path;
    case TargetPlatform.windows:
      return (await getApplicationSupportDirectory()).path;
    default:
      throw Exception('Unsupported platform');
  }
}

Directory getFontDir({String? path}) {
  path ??= documentPath;
  return Directory('$path${Platform.pathSeparator}font');
}

Directory getCoverDir({String? path}) {
  path ??= documentPath;
  return Directory('$path${Platform.pathSeparator}cover');
}

Directory getFileDir({String? path}) {
  path ??= documentPath;
  return Directory('$path${Platform.pathSeparator}file');
}

void initBasePath() async {
  Directory appDocDir = await getHDocumentDir();
  documentPath = appDocDir.path;
  debugPrint('documentPath: $documentPath');
  final fileDir = getFileDir();
  final coverDir = getCoverDir();
  final fontDir = getFontDir();
  if (!fileDir.existsSync()) {
    fileDir.createSync();
  }
  if (!coverDir.existsSync()) {
    coverDir.createSync();
  }
  if (!fontDir.existsSync()) {
    fontDir.createSync();
  }
}

Future<Directory> getHDocumentDir() async {
  return Directory(await getHDocmentsPath());
}

String getBasePath(String path) {
  // the path that in database using "/"
  path.replaceAll("/", Platform.pathSeparator);
  return '$documentPath${Platform.pathSeparator}$path';
}
