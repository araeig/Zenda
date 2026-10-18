import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeType { light, dark, twilight, eclipse }

class ThemeColors {
  final Color bgA;
  final Color bgB;
  final Color blob1;
  final Color blob2;
  final Color blob3;
  final Color text;
  final Color textMuted;
  final Color accent;
  final Color accent2;
  final Color onAccent;
  final Color cardBg;
  final Color navBg;
  final Color navBorder;
  final Color danger;
  final Color glassBg;
  final Color glassBorder;
  final Color ringTrack;

  const ThemeColors({
    required this.bgA,
    required this.bgB,
    required this.blob1,
    required this.blob2,
    required this.blob3,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.accent2,
    required this.onAccent,
    required this.cardBg,
    required this.navBg,
    required this.navBorder,
    required this.danger,
    required this.glassBg,
    required this.glassBorder,
    required this.ringTrack,
  });
}

const Map<AppThemeType, ThemeColors> appThemes = {
  AppThemeType.light: ThemeColors(
    bgA: Color(0xFFFDF1F6),
    bgB: Color(0xFFDCD9F2),
    blob1: Color(0xFFF0C7DD),
    blob2: Color(0xFFA9ABDD),
    blob3: Color(0xFFC48BC9),
    text: Color(0xFF2A0A3D),
    textMuted: Color(0xFF7A6486),
    accent: Color(0xFF7B337E),
    accent2: Color(0xFF6667AB),
    onAccent: Color(0xFFFDF6FA),
    cardBg: Colors.white,
    navBg: Color(0x99FFFFFF),
    navBorder: Color(0xB3FFFFFF),
    danger: Color(0xFFC2456B),
    glassBg: Color(0x8CFFFFFF),
    glassBorder: Color(0xA6FFFFFF),
    ringTrack: Color(0x297B337E),
  ),
  AppThemeType.dark: ThemeColors(
    bgA: Color(0xFF210635),
    bgB: Color(0xFF420D4B),
    blob1: Color(0xFF6667AB),
    blob2: Color(0xFF7B337E),
    blob3: Color(0xFF420D4B),
    text: Color(0xFFF5D5E0),
    textMuted: Color(0xFFBFA0C6),
    accent: Color(0xFFA6A5E6),
    accent2: Color(0xFFCF82D4),
    onAccent: Color(0xFF210635),
    cardBg: Color(0xFFF5D5E0),
    navBg: Color(0x8C210635),
    navBorder: Color(0x1FF5D5E0),
    danger: Color(0xFFF28BA8),
    glassBg: Color(0x12F5D5E0),
    glassBorder: Color(0x29F5D5E0),
    ringTrack: Color(0x24F5D5E0),
  ),
  AppThemeType.twilight: ThemeColors(
    bgA: Color(0xFF6667AB),
    bgB: Color(0xFF7B337E),
    blob1: Color(0xFFF5D5E0),
    blob2: Color(0xFF420D4B),
    blob3: Color(0xFF9695D6),
    text: Color(0xFFFDF1F6),
    textMuted: Color(0xFFE9D9EE),
    accent: Color(0xFFF5D5E0),
    accent2: Colors.white,
    onAccent: Color(0xFF420D4B),
    cardBg: Colors.white,
    navBg: Color(0x736667AB),
    navBorder: Color(0x40FFFFFF),
    danger: Color(0xFFFFC7D6),
    glassBg: Color(0x26FFFFFF),
    glassBorder: Color(0x4DFFFFFF),
    ringTrack: Color(0x33FFFFFF),
  ),
  AppThemeType.eclipse: ThemeColors(
    bgA: Color(0xFF12021F),
    bgB: Color(0xFF2C0838),
    blob1: Color(0xFF7B337E),
    blob2: Color(0xFF6667AB),
    blob3: Color(0xFF420D4B),
    text: Color(0xFFF5D5E0),
    textMuted: Color(0xFFB48CA6),
    accent: Color(0xFFC774CC),
    accent2: Color(0xFF8F8EE0),
    onAccent: Color(0xFF12021F),
    cardBg: Color(0xFF7B337E),
    navBg: Color(0xA612021F),
    navBorder: Color(0x33B85FBE),
    danger: Color(0xFFF07A9E),
    glassBg: Color(0x217B337E),
    glassBorder: Color(0x52B85FBE),
    ringTrack: Color(0x2EB85FBE),
  ),
};

const Map<AppThemeType, String> themeBackgrounds = {
  AppThemeType.light: 'assets/images/bg_light.png',
  AppThemeType.dark: 'assets/images/bg_dark.png',
  AppThemeType.twilight: 'assets/images/bg_twilight.png',
  AppThemeType.eclipse: 'assets/images/bg_eclipse.png',
};

const Map<AppThemeType, String> themeLogos = {
  AppThemeType.light: 'assets/images/zenda_wordmark_dark.png',
  AppThemeType.dark: 'assets/images/zenda_wordmark.png',
  AppThemeType.twilight: 'assets/images/zenda_wordmark.png',
  AppThemeType.eclipse: 'assets/images/zenda_wordmark.png',
};

const Map<AppThemeType, String> themeMoonIcons = {
  AppThemeType.light: 'assets/icons/moon_light.svg',
  AppThemeType.dark: 'assets/icons/moon_dark.svg',
  AppThemeType.twilight: 'assets/icons/moon_twilight.svg',
  AppThemeType.eclipse: 'assets/icons/moon_eclipse.svg',
};

final ValueNotifier<AppThemeType> currentTheme = ValueNotifier<AppThemeType>(
  AppThemeType.light,
);

Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final index = prefs.getInt('themeIndex') ?? 0;
  currentTheme.value = AppThemeType.values[index];
}

Future<void> setTheme(AppThemeType theme) async {
  currentTheme.value = theme;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('themeIndex', theme.index);
}
