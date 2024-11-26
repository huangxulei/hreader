import 'package:flutter/foundation.dart';
import 'package:hreader/utils/get_path/get_base_path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<String> getHDataBasesPath() async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      final path = await getDatabasesPath();
      return path;
    case TargetPlatform.windows:
      final documentsPath = await getHDocmentsPath();
      return '$documentsPath\\databases';
    default:
      throw Exception('Unsupported platform');
  }
}
