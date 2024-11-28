import 'package:flutter/material.dart';
import 'package:hreader/enums/convert_chinese_mode.dart';
import 'package:hreader/main.dart';
import 'package:hreader/model/book_style.dart';
import 'package:hreader/model/font_model.dart';
import 'package:hreader/model/read_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs extends ChangeNotifier {
  late SharedPreferences prefs;

  static final Prefs _instance = Prefs._internal();
  factory Prefs() {
    return _instance;
  }

  Prefs._internal() {
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    saveBeginDate();
    notifyListeners();
  }

  void saveBeginDate() {
    String? beginDate = prefs.getString('beginDate');
    if (beginDate == null) {
      prefs.setString('beginDate', DateTime.now().toIso8601String());
    }
  }

  Locale? get locale {
    String? localeCode = prefs.getString('locale');
    if (localeCode == null || localeCode == '') return null;
    return Locale(localeCode);
  }

  ThemeMode get themeMode {
    String themeMode = prefs.getString('themeMode') ?? 'system';
    switch (themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  BookStyle get bookStyle {
    String? bookStyleJson = prefs.getString('readStyle');
    if (bookStyleJson == null) return BookStyle();
    return BookStyle.fromJson(bookStyleJson);
  }

  ReadTheme get readTheme {
    String? readThemeJson = prefs.getString('readTheme');
    if (readThemeJson == null) {
      return ReadTheme(
          backgroundColor: 'FFFBFBF3',
          textColor: 'FF343434',
          backgroundImagePath: '');
    }
    return ReadTheme.fromJson(readThemeJson);
  }

  FontModel get font {
    String? fontJson = prefs.getString('font');
    BuildContext context = navigatorKey.currentContext!;
    if (fontJson == null) {
      return FontModel(label: "follow_book", name: 'book', path: '');
    }
    return FontModel.fromJson(fontJson);
  }

  // PageTurn get pageTurnStyle {
  //   String? style = prefs.getString('pageTurnStyle');
  //   if (style == null) return PageTurn.slide;
  //   return PageTurn.values.firstWhere((element) => element.name == style);
  // }

  ConvertChineseMode get convertChineseMode {
    return getConvertChineseMode(
        prefs.getString('convertChineseMode') ?? 'none');
  }
}
