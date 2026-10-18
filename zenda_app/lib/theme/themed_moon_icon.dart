import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zenda_app/theme/app_theme.dart';

class ThemedMoonIcon extends StatelessWidget {
  final double size;

  const ThemedMoonIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: currentTheme,
      builder: (context, theme, _) {
        final path = themeMoonIcons[theme]!;
        if (path.endsWith('.svg')) {
          return SvgPicture.asset(path, width: size, height: size);
        }
        return Image.asset(path, width: size, height: size);
      },
    );
  }
}