import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:zenda_app/check.dart';
import 'package:zenda_app/home.dart';
import 'package:zenda_app/l10n/app_localizations.dart';
import 'package:zenda_app/pages/auth/forgot_password_page.dart';
import 'package:zenda_app/pages/auth/login_page.dart';
import 'package:zenda_app/pages/auth/register_page.dart';
import 'package:zenda_app/pages/auth/welcome_page.dart';
import 'package:zenda_app/services/locale_service.dart';
import 'package:zenda_app/theme/app_theme.dart';
import 'package:zenda_app/widgets/zenda_toast.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
  await loadSavedTheme();
  await loadSavedLocale();
  runApp(const ZendaApp());
}

class ZendaApp extends StatelessWidget {
  const ZendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([currentTheme, currentLocale]),
      builder: (context, _) {
        final theme = currentTheme.value;
        return MaterialApp(
          title: 'Zenda',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          locale: currentLocale.value,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Manrope',
            brightness: theme == AppThemeType.light
                ? Brightness.light
                : Brightness.dark,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const Check(),
            '/welcome': (context) => const WelcomePage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),
            '/home': (context) => const Home(),
          },
        );
      },
    );
  }
}
