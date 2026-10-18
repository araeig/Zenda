import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/themed_background.dart';
import '../../theme/themed_moon_icon.dart';
import '../../widgets/zenda_text_field.dart';
import '../../widgets/zenda_toast.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;
  String? _emailError;
  String? _passError;
  int _shakeTick = 0;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _emailError = emailController.text.trim().isEmpty
          ? t.fieldRequired
          : null;
      _passError = passController.text.isEmpty ? t.fieldRequired : null;
      _shakeTick++;
    });
    if (_emailError != null || _passError != null) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final result = await authService.signIn(
      emailController.text.trim(),
      passController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (authService.lastError != null) {
      showZendaToast(
        context,
        authService.lastError!,
        subtitle: t.authCheckData,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const ThemedMoonIcon(size: 61),
                    const SizedBox(height: 24),
                    Text(
                      t.authWelcomeBack,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.authSignInSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 32),
                    _label(t.fieldEmail, colors),
                    const SizedBox(height: 8),
                    ZendaTextField(
                      controller: emailController,
                      hint: t.hintEmail,
                      colors: colors,
                      errorText: _emailError,
                      shakeTick: _shakeTick,
                      onChanged: (_) {
                        if (_emailError != null)
                          setState(() => _emailError = null);
                      },
                    ),
                    const SizedBox(height: 16),
                    _label(t.fieldPassword, colors),
                    const SizedBox(height: 8),
                    ZendaTextField(
                      controller: passController,
                      hint: '••••••••',
                      colors: colors,
                      obscure: true,
                      errorText: _passError,
                      shakeTick: _shakeTick,
                      onChanged: (_) {
                        if (_passError != null)
                          setState(() => _passError = null);
                      },
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/forgot-password'),
                        child: Text(
                          t.authForgotLink,
                          style: TextStyle(color: colors.accent, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        onPressed: _isLoading ? null : _handleSignIn,
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
                                t.authSignIn,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          t.authNoAccount,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text(
                            t.authSignUp,
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
