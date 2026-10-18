import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> supportedLanguageCodes = ['ru', 'en', 'zh', 'ar'];

const Map<String, String> languageNames = {
  'ru': 'Русский',
  'en': 'English',
  'zh': '中文',
  'ar': 'العربية',
};

const Map<String, int> languageIds = {'ru': 1, 'en': 2, 'zh': 3, 'ar': 4};

final ValueNotifier<Locale> currentLocale = ValueNotifier(const Locale('ru'));

const String _localeKey = 'languageCode';

String languageCodeForId(dynamic id) {
  for (final entry in languageIds.entries) {
    if (entry.value == id) return entry.key;
  }
  return 'ru';
}

Future<void> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(_localeKey);
  if (code != null && supportedLanguageCodes.contains(code)) {
    currentLocale.value = Locale(code);
  }
}

Future<void> setLocale(String code) async {
  if (!supportedLanguageCodes.contains(code)) return;
  currentLocale.value = Locale(code);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_localeKey, code);
}
