import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum ZendaToastType { error, success }

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

OverlayEntry? _activeToast;
bool _activeIsPriority = false;

void showZendaToast(
  BuildContext context,
  String title, {
  String? subtitle,
  ZendaToastType type = ZendaToastType.error,
}) {
  _insertToast(Overlay.of(context, rootOverlay: true), title, subtitle, type, false);
}

void showZendaToastGlobal(
  String title, {
  String? subtitle,
  ZendaToastType type = ZendaToastType.error,
  bool priority = false,
}) {
  final overlay = navigatorKey.currentState?.overlay;
  if (overlay == null) return;
  _insertToast(overlay, title, subtitle, type, priority);
}

void _insertToast(
  OverlayState overlay,
  String title,
  String? subtitle,
  ZendaToastType type,
  bool priority,
) {
  if (_activeToast != null && _activeToast!.mounted) {
    if (_activeIsPriority && type == ZendaToastType.error) return;
    _activeToast!.remove();
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ZendaToast(
      title: title,
      subtitle: subtitle,
      type: type,
      onDismissed: () {
        if (entry.mounted) entry.remove();
        if (_activeToast == entry) {
          _activeToast = null;
          _activeIsPriority = false;
        }
      },
    ),
  );
  _activeToast = entry;
  _activeIsPriority = priority;
  overlay.insert(entry);
  if (type == ZendaToastType.error) {
    HapticFeedback.lightImpact();
  } else {
    HapticFeedback.selectionClick();
  }
}

class _ZendaToast extends StatefulWidget {
  final String title;
  final String? subtitle;
  final ZendaToastType type;
  final VoidCallback onDismissed;

  const _ZendaToast({
    required this.title,
    this.subtitle,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_ZendaToast> createState() => _ZendaToastState();
}

class _ZendaToastState extends State<_ZendaToast> with TickerProviderStateMixin {
  late final AnimationController _slide =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  late final AnimationController _life =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3500));
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _life.addStatusListener((status) {
      if (status == AnimationStatus.completed) _dismiss();
    });
    _slide.forward();
    _life.forward();
  }

  Future<void> _dismiss() async {
    if (_closing || !mounted) return;
    _closing = true;
    _life.stop();
    await _slide.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _slide.dispose();
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = appThemes[currentTheme.value]!;
    final isSuccess = widget.type == ZendaToastType.success;
    final moonColor = isSuccess ? colors.accent : colors.danger;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1.4), end: Offset.zero).animate(
          CurvedAnimation(parent: _slide, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic),
        ),
        child: FadeTransition(
          opacity: _slide,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < 0) _dismiss();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.navBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.navBorder),
                    ),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _life,
                          builder: (context, _) => CustomPaint(
                            size: const Size(20, 20),
                            painter: _MoonPainter(
                              progress: _life.value,
                              color: moonColor,
                              waxing: isSuccess,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.title,
                                  style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w700)),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(widget.subtitle!,
                                    style: TextStyle(color: colors.textMuted, fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool waxing;

  _MoonPainter({required this.progress, required this.color, required this.waxing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 1;
    final shift = waxing ? -2 * radius * progress : 2 * radius * (1 - progress);
    final disc = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final shadow = Path()..addOval(Rect.fromCircle(center: center.translate(shift, 0), radius: radius));
    canvas.drawPath(Path.combine(PathOperation.difference, disc, shadow), Paint()..color = color);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_MoonPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.waxing != waxing;
}