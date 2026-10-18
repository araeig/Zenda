import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class ZendaNavItem {
  final String iconPath;
  final String label;

  const ZendaNavItem({required this.iconPath, required this.label});
}

class ZendaNavBar extends StatelessWidget {
  final List<ZendaNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ThemeColors colors;

  const ZendaNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.colors,
  });

  static const Duration _duration = Duration(milliseconds: 300);
  static const Curve _curve = Curves.easeOutCubic;
  static const double _height = 62;
  static const double _iconBox = 17;
  static const double _selectedScale = 1.25;
  static const double _indicatorWidth = 18;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;
          return Stack(
            children: [
              Row(
                children: List.generate(items.length, (index) {
                  return _buildItem(
                    items[index],
                    index == currentIndex,
                    () => onTap(index),
                  );
                }),
              ),
              AnimatedPositionedDirectional(
                duration: _duration,
                curve: _curve,
                start:
                    itemWidth * currentIndex +
                    (itemWidth - _indicatorWidth) / 2,
                bottom: 17,
                child: Container(
                  width: _indicatorWidth,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(ZendaNavItem item, bool selected, VoidCallback onItemTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onItemTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _iconBox,
              child: Align(
                alignment: Alignment.topCenter,
                child: AnimatedScale(
                  scale: selected ? _selectedScale : 1.0,
                  duration: _duration,
                  curve: _curve,
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: selected ? colors.text : colors.textMuted,
                    ),
                    duration: _duration,
                    builder: (context, color, _) {
                      return SvgPicture.asset(
                        item.iconPath,
                        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedOpacity(
              opacity: selected ? 0 : 1,
              duration: _duration,
              curve: _curve,
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
