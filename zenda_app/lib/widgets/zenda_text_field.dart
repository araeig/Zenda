import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ZendaTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ThemeColors colors;
  final bool obscure;
  final String? errorText;
  final int shakeTick;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const ZendaTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.colors,
    this.obscure = false,
    this.errorText,
    this.shakeTick = 0,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  State<ZendaTextField> createState() => _ZendaTextFieldState();
}

class _ZendaTextFieldState extends State<ZendaTextField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(ZendaTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && widget.shakeTick != oldWidget.shakeTick) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final hasError = widget.errorText != null;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: hasError
          ? BorderSide(color: colors.danger, width: 1.5)
          : BorderSide.none,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            final t = _shake.value;
            return Transform.translate(
              offset: Offset(sin(t * pi * 4) * 6 * (1 - t), 0),
              child: child,
            );
          },
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscure,
            maxLines: widget.obscure ? 1 : widget.maxLines,
            minLines: 1,
            onChanged: widget.onChanged,
            style: TextStyle(color: colors.text),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: colors.textMuted.withOpacity(0.7)),
              filled: true,
              fillColor: colors.cardBg.withOpacity(0.5),
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colors.danger, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.errorText!,
                          style: TextStyle(color: colors.danger, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
