import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> getHCacheDir() async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return await getApplicationCacheDirectory();
    case TargetPlatform.windows:
      return await getApplicationCacheDirectory();
    default:
      throw Exception('Unsupported platform');
  }
}
