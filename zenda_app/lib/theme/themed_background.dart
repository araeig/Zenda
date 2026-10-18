import 'package:flutter/material.dart';
import 'package:zenda_app/theme/app_theme.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: currentTheme,
      builder: (context, theme, _) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(themeBackgrounds[theme]!),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        );
      },
    );
  }
}