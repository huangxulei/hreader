import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hreader/config/shared_preference_provider.dart';
import 'package:hreader/model/book_style.dart';
import 'package:hreader/model/read_theme.dart';
import 'package:hreader/utils/js/convert_dart_color_to_js.dart';

void webviewInitialVariable(
  InAppWebViewController controller,
  String url,
  String cfi, {
  BookStyle? bookStyle,
  int? textIndent,
  String? textColor,
  String? fontName,
  String? fontPath,
  String? backgroundColor,
  bool? importing,
}) {
  ReadTheme readTheme = Prefs().readTheme;
  bookStyle ??= Prefs().bookStyle;
  textColor ??= convertDartColorToJs(readTheme.textColor);
  fontName ??= Prefs().font.name;
  fontPath ??= Prefs().font.path;
  backgroundColor ??= convertDartColorToJs(readTheme.backgroundColor);
  importing ??= false;

  const minWebviewVersion = 92;

  String replaceSingleQuote(String value) {
    return value.replaceAll("'", "\\'");
  }

  final script = '''
     console.log(navigator.userAgent)
     const webviewVersion = navigator.userAgent.match(/Chrome\\/(\\d+)/)?.[1]
     console.log('webviewVersion', webviewVersion)
     if (webviewVersion && webviewVersion < $minWebviewVersion || !webviewVersion) {
       window.flutter_inappwebview.callHandler('webviewVersion', webviewVersion)
     }
     const importing = $importing
     const url = '${replaceSingleQuote(url)}'
     let initialCfi = '${replaceSingleQuote(cfi)}'
     let style = {
         fontSize: ${bookStyle.fontSize},
         fontName: '${replaceSingleQuote(fontName)}',
         fontPath: '${replaceSingleQuote(fontPath)}',
         letterSpacing: ${bookStyle.letterSpacing},
         spacing: ${bookStyle.lineHeight},
         paragraphSpacing: ${bookStyle.paragraphSpacing},
         textIndent: ${bookStyle.indent},
         fontColor: '#$textColor',
         backgroundColor: '#$backgroundColor',
         topMargin: ${bookStyle.topMargin},
         bottomMargin: ${bookStyle.bottomMargin},
         sideMargin: ${bookStyle.sideMargin},
         justify: true,
         hyphenate: true,
     }
     let convertChineseMode = '${Prefs().convertChineseMode.name}'
  ''';
  controller.addJavaScriptHandler(
      handlerName: 'webviewInitialVariable',
      callback: (args) async {
        await controller.evaluateJavascript(source: script);
        return null;
      });
  controller.addJavaScriptHandler(
      handlerName: 'webviewVersion',
      callback: (args) async {
        SmartDialog.show(
          animationType: SmartAnimationType.fade,
          builder: (context) {
            final version = args[0];
            return AlertDialog(
              title: const Center(
                child: Icon(Icons.warning_rounded),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("webview_unsupported_version",
                      style: Theme.of(context).textTheme.titleMedium),
                  Text("this..."),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      SmartDialog.dismiss();
                    },
                    child: Text("webview_cancel")),
                // TextButton(
                //     onPressed: () {
                //     },
                //     child: Text(L10n.of(context).webview_update))
              ],
            );
          },
        );
        return null;
      });
}
