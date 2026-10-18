import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/themed_background.dart';
import '../../widgets/zenda_text_field.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passError;
  String? _confirmError;
  int _shakeTick = 0;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _firstNameError = firstNameController.text.trim().isEmpty
          ? t.fieldRequired
          : null;
      _lastNameError = lastNameController.text.trim().isEmpty
          ? t.fieldRequired
          : null;
      _emailError = emailController.text.trim().isEmpty
          ? t.fieldRequired
          : null;
      if (passController.text.isEmpty) {
        _passError = t.fieldRequired;
      } else if (passController.text.length < 8) {
        _passError = t.passwordTooShort;
      } else {
        _passError = null;
      }
      if (confirmController.text.isEmpty) {
        _confirmError = t.fieldRequired;
      } else if (confirmController.text != passController.text) {
        _confirmError = t.passwordsMismatch;
      } else {
        _confirmError = null;
      }
      _shakeTick++;
    });
    if ([
      _firstNameError,
      _lastNameError,
      _emailError,
      _passError,
      _confirmError,
    ].any((e) => e != null)) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final result = await authService.signUp(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      password: passController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (authService.lastError != null) {
      setState(() {
        _emailError = authService.lastError;
        _shakeTick++;
      });
      HapticFeedback.lightImpact();
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
                    const SizedBox(height: 32),
                    Text(
                      t.authCreateAccount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.authCreateSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    _label(t.fieldFirstName, colors),
                    const SizedBox(height: 8),
                    ZendaTextField(
                      controller: firstNameController,
                      hint: t.hintFirstName,
                      colors: colors,
                      errorText: _firstNameError,
                      shakeTick: _shakeTick,
                      onChanged: (_) {
                        if (_firstNameError != null)
                          setState(() => _firstNameError = null);
                      },
                    ),
                    const SizedBox(height: 14),
                    _label(t.fieldLastName, colors),
                    const SizedBox(height: 8),
                    ZendaTextField(
                      controller: lastNameController,
                      hint: t.hintLastName,
                      colors: colors,
                      errorText: _lastNameError,
                      shakeTick: _shakeTick,
                      onChanged: (_) {
                        if (_lastNameError != null)
                          setState(() => _lastNameError = null);
                      },
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 14),
                    _label(t.fieldConfirmPassword, colors),
                    const SizedBox(height: 8),
                    ZendaTextField(
                      controller: confirmController,
                      hint: '••••••••',
                      colors: colors,
                      obscure: true,
                      errorText: _confirmError,
                      shakeTick: _shakeTick,
                      onChanged: (_) {
                        if (_confirmError != null)
                          setState(() => _confirmError = null);
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
                        onPressed: _isLoading ? null : _handleSignUp,
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
                                t.authSignUp,
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
                          t.authHaveAccount,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            t.authSignIn,
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
