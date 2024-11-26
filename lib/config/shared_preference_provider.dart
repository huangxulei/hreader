import 'package:flutter/material.dart';
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
}
