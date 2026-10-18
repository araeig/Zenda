import 'package:flutter/material.dart';
import 'app_theme.dart';

Widget zendaPickerTheme(BuildContext context, Widget? child) {
  final colors = appThemes[currentTheme.value]!;
  final base = Theme.of(context);
  return Theme(
    data: base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: colors.accent,
        onPrimary: colors.onAccent,
        surface: colors.bgA,
        onSurface: colors.text,
        surfaceContainerHigh: colors.bgA,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.accent),
      ),
    ),
    child: child!,
  );
}