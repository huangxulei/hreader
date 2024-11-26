import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hreader/utils/log/common.dart';

class HError {
  static Future<void> init() async {
    HLog.info('AnxError init');
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      HLog.severe(details.exceptionAsString(), details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      HLog.severe(error.toString(), stack);
      return true;
    };
  }
}
