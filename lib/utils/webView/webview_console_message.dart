import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hreader/utils/log/common.dart';

void webviewConsoleMessage(controller, consoleMessage) {
  if (consoleMessage.message.contains(
      "An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing")) {
    return;
  }
  if (consoleMessage.messageLevel == ConsoleMessageLevel.LOG) {
    HLog.info('Webview: ${consoleMessage.message}');
  } else if (consoleMessage.messageLevel == ConsoleMessageLevel.WARNING) {
    HLog.warning('Webview: ${consoleMessage.message}');
  } else if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
    HLog.severe('Webview: ${consoleMessage.message}');
  }
}
