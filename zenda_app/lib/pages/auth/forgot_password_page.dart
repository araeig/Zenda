import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/themed_background.dart';
import '../../widgets/zenda_text_field.dart';
import '../../widgets/zenda_toast.dart';
import '../../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;
  bool _sent = false;
  String? _emailError;
  int _shakeTick = 0;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _emailError = emailController.text.trim().isEmpty
          ? t.fieldRequired
          : null;
      _shakeTick++;
    });
    if (_emailError != null) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final success = await authService.forgotPassword(
      emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = success;
    });

    if (!success) {
      showZendaToast(
        context,
        t.forgotSendError,
        subtitle: t.forgotSendErrorSubtitle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: currentTheme,
      builder: (context, theme, _) {
        final colors = appThemes[theme]!;
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Center(
                  child: SingleChildScrollView(
                    child: _sent
                        ? _successView(colors, t)
                        : _formView(colors, t),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _formView(ThemeColors colors, AppLocalizations t) {
    return Column(
      children: [
        Text(
          t.forgotTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t.forgotSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 28),
        _label(t.fieldEmail, colors),
        const SizedBox(height: 8),
        ZendaTextField(
          controller: emailController,
          hint: t.hintEmail,
          colors: colors,
          errorText: _emailError,
          shakeTick: _shakeTick,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isLoading ? null : _handleSend,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: colors.onAccent,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    t.forgotSend,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            t.backToLogin,
            style: TextStyle(
              color: colors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _successView(ThemeColors colors, AppLocalizations t) {
    return Column(
      children: [
        Icon(Icons.mail_outline, color: colors.accent, size: 44),
        const SizedBox(height: 14),
        Text(
          t.forgotSentTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
            children: [
              TextSpan(text: t.forgotSentBefore),
              TextSpan(
                text: emailController.text.trim(),
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: t.forgotSentAfter),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            t.backToLogin,
            style: TextStyle(
              color: colors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, ThemeColors colors) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
