import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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
