import 'package:flutter/material.dart';
import 'package:zenda_app/l10n/app_localizations.dart';
import 'package:zenda_app/theme/app_theme.dart';
import 'package:zenda_app/theme/themed_background.dart';
import 'package:zenda_app/widgets/zenda_nav_bar.dart';
import 'package:zenda_app/pages/home_page.dart';
import 'package:zenda_app/pages/calendar_page.dart';
import 'package:zenda_app/pages/tasks_page.dart';
import 'package:zenda_app/pages/assistant_page.dart';
import 'package:zenda_app/pages/profile_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CalendarPage(),
    TasksPage(),
    AssistantPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final navItems = [
      ZendaNavItem(iconPath: 'assets/icons/nav_home.svg', label: t.navHome),
      ZendaNavItem(
        iconPath: 'assets/icons/nav_calendar.svg',
        label: t.navCalendar,
      ),
      ZendaNavItem(iconPath: 'assets/icons/nav_tasks.svg', label: t.navTasks),
      ZendaNavItem(
        iconPath: 'assets/icons/nav_assistant.svg',
        label: t.navAssistant,
      ),
      ZendaNavItem(
        iconPath: 'assets/icons/nav_profile.svg',
        label: t.navProfile,
      ),
    ];

    return ValueListenableBuilder<AppThemeType>(
      valueListenable: currentTheme,
      builder: (context, theme, _) {
        final colors = appThemes[theme]!;
        return Scaffold(
          extendBody: true,
          body: ThemedBackground(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: colors.navBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.navBorder),
              ),
              child: ZendaNavBar(
                items: navItems,
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                colors: colors,
              ),
            ),
          ),
        );
      },
    );
  }
}
