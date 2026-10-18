import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenda_app/home.dart';
import 'package:zenda_app/pages/auth/welcome_page.dart';

class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> with SingleTickerProviderStateMixin {
  static const Color _background = Color(0xFF2F1542);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final Animation<double> _tagline = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 0.9, curve: Curves.easeOut),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.06,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _hasSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final token = prefs.getString('token');
      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      print('Ошибка проверки сессии: $e');
      return false;
    }
  }

  Future<void> _start() async {
    final results = await Future.wait<dynamic>([
      _hasSession(),
      Future.delayed(const Duration(milliseconds: 1600)),
    ]);
    if (!mounted) return;
    final hasSession = results[0] as bool;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: RouteSettings(name: hasSession ? '/home' : '/welcome'),
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            hasSession ? const Home() : const WelcomePage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: SizedBox.expand(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _scale.value,
                    child: Image.asset(
                      'assets/images/zenda_wordmark.png',
                      width: 160,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, 52 + 8 * (1 - _tagline.value)),
                    child: Opacity(
                      opacity: _tagline.value,
                      child: Text(
                        'zen for your agenda',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
