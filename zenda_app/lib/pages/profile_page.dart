import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/data_events.dart';
import '../services/locale_service.dart';
import '../services/profile_service.dart';
import '../services/reminder_service.dart';
import '../widgets/user_avatar.dart';
import '../widgets/zenda_toast.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService authService = AuthService();
  final ProfileService profileService = ProfileService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _hasError = false;
  bool _notificationsOn = true;

  static const Map<AppThemeType, Color> _themeDots = {
    AppThemeType.light: Color(0xFFF0C7DD),
    AppThemeType.dark: Color(0xFF420D4B),
    AppThemeType.twilight: Color(0xFF6667AB),
    AppThemeType.eclipse: Color(0xFF12021F),
  };

  @override
  void initState() {
    super.initState();
    dataVersion.addListener(_load);
    _loadNotifications();
    _load();
  }

  @override
  void dispose() {
    dataVersion.removeListener(_load);
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () =>
          _notificationsOn = prefs.getBool(ReminderService.enabledKey) ?? true,
    );
  }

  Future<void> _toggleNotifications() async {
    final value = !_notificationsOn;
    setState(() => _notificationsOn = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ReminderService.enabledKey, value);
    if (!mounted) return;
    final t = AppLocalizations.of(context);

    if (!ReminderService.supported) {
      if (value) {
        showZendaToast(
          context,
          t.remindersOnTitle,
          subtitle: t.remindersOnWebSubtitle,
          type: ZendaToastType.success,
        );
      }
      return;
    }

    if (value) {
      final granted = await ReminderService.requestPermission();
      await ReminderService.sync();
      if (!mounted) return;
      if (granted) {
        showZendaToast(
          context,
          t.remindersOnTitle,
          subtitle: t.remindersOnSubtitle,
          type: ZendaToastType.success,
        );
      } else {
        showZendaToast(
          context,
          t.remindersPermissionTitle,
          subtitle: t.remindersPermissionSubtitle,
        );
      }
    } else {
      await ReminderService.cancelAll();
      if (mounted)
        showZendaToast(
          context,
          t.remindersOffTitle,
          type: ZendaToastType.success,
        );
    }
  }

  Future<void> _load() async {
    final profile = await profileService.get();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = profile == null;
      if (profile != null) _profile = profile;
    });
    if (profile != null) {
      final code = languageCodeForId(profile['languageId']);
      if (code != currentLocale.value.languageCode) await setLocale(code);
    }
  }

  void _openEdit() {
    final profile = _profile;
    if (profile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(profile: profile)),
    );
  }

  Future<void> _logOut() async {
    await ReminderService.cancelAll();
    await authService.logOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  Future<void> _openLanguagePicker(ThemeColors colors) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _languageSheet(sheetContext, colors),
    );
    if (selected == null ||
        selected == currentLocale.value.languageCode ||
        !mounted)
      return;

    await setLocale(selected);
    final ok = await profileService.updateLanguage(languageIds[selected]!);
    if (!mounted || ok) return;
    final t = AppLocalizations.of(context);
    showZendaToast(
      context,
      t.languageSaveError,
      subtitle: profileService.lastError,
    );
  }

  void _showAbout(ThemeColors colors) {
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          28 + MediaQuery.of(sheetContext).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: colors.bgA,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: colors.glassBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(colors),
            const SizedBox(height: 22),
            Image.asset(themeLogos[currentTheme.value]!, width: 150),
            const SizedBox(height: 6),
            Text(
              'zen for your agenda',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.aboutDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.text, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 10),
            Text(
              t.aboutVersion('1.0'),
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: currentTheme,
      builder: (context, theme, _) {
        final colors = appThemes[theme]!;
        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: colors.accent,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
              children: _content(colors, theme),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _content(ThemeColors colors, AppThemeType theme) {
    final t = AppLocalizations.of(context);
    if (_isLoading) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(
            child: CircularProgressIndicator(
              color: colors.accent,
              strokeWidth: 2,
            ),
          ),
        ),
      ];
    }
    final profile = _profile;
    if (_hasError || profile == null) {
      return [
        _messageCard(t.profileLoadError, t.pullToRetry, colors),
        const SizedBox(height: 16),
        _logoutButton(colors, t),
      ];
    }

    final firstName = (profile['firstName'] ?? '').toString();
    final lastName = (profile['lastName'] ?? '').toString();
    final workplace = (profile['workplace'] ?? '').toString().trim();
    final stats = profile['stats'] ?? {};
    final int completed = stats['completedThisWeek'] ?? 0;
    final int streak = stats['streakDays'] ?? 0;
    final int active = stats['activeProjects'] ?? 0;

    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: GestureDetector(
          onTap: _openEdit,
          child: UserAvatar(
            firstName: firstName,
            lastName: lastName,
            avatarUrl: profile['avatarUrl'],
            size: 72,
            colors: colors,
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text(
        '$firstName $lastName',
        style: TextStyle(
          color: colors.text,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (workplace.isNotEmpty) ...[
        const SizedBox(height: 2),
        Text(
          workplace,
          style: TextStyle(color: colors.textMuted, fontSize: 12, height: 1.4),
        ),
      ],
      const SizedBox(height: 12),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: GestureDetector(
          onTap: _openEdit,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.glassBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 14, color: colors.text),
                const SizedBox(width: 6),
                Text(
                  t.profileEdit,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          _statCard('$completed', t.profileStatCompleted(completed), colors),
          const SizedBox(width: 10),
          _statCard('$streak', t.profileStatStreak(streak), colors),
          const SizedBox(width: 10),
          _statCard('$active', t.profileStatActive(active), colors),
        ],
      ),
      const SizedBox(height: 20),
      Text(
        t.settingsTitle,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Column(
          children: [
            _settingsRow(
              Icons.wb_sunny_outlined,
              t.settingsTheme,
              _themePicker(colors, theme),
              null,
              colors,
            ),
            _divider(colors),
            _settingsRow(
              Icons.notifications_none_rounded,
              t.settingsNotifications,
              Text(
                _notificationsOn ? t.notificationsOn : t.notificationsOff,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _toggleNotifications,
              colors,
            ),
            _divider(colors),
            _settingsRow(
              Icons.language_rounded,
              t.settingsLanguage,
              Text(
                languageNames[currentLocale.value.languageCode] ?? 'Русский',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              () => _openLanguagePicker(colors),
              colors,
            ),
            _divider(colors),
            _settingsRow(
              Icons.info_outline_rounded,
              t.settingsAbout,
              null,
              () => _showAbout(colors),
              colors,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _logoutButton(colors, t),
    ];
  }

  Widget _statCard(String value, String label, ThemeColors colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: colors.text,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsRow(
    IconData icon,
    String title,
    Widget? trailing,
    VoidCallback? onTap,
    ThemeColors colors,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _themePicker(ThemeColors colors, AppThemeType current) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AppThemeType.values.map((type) {
        final selected = type == current;
        return GestureDetector(
          onTap: () => setTheme(type),
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsetsDirectional.only(start: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: colors.accent, width: 1.5)
                  : null,
            ),
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: _themeDots[type],
                shape: BoxShape.circle,
                border: Border.all(color: colors.glassBorder),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _languageSheet(BuildContext sheetContext, ThemeColors colors) {
    final t = AppLocalizations.of(sheetContext);
    final current = currentLocale.value.languageCode;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        16 + MediaQuery.of(sheetContext).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.bgA,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: colors.glassBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sheetHandle(colors),
          const SizedBox(height: 18),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              t.settingsLanguage,
              style: TextStyle(
                color: colors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final code in supportedLanguageCodes)
            GestureDetector(
              onTap: () => Navigator.pop(sheetContext, code),
              child: Container(
                height: 52,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.glassBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: code == current ? colors.accent : colors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        languageNames[code]!,
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (code == current)
                      Icon(Icons.check_rounded, size: 20, color: colors.accent),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sheetHandle(ThemeColors colors) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colors.textMuted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _divider(ThemeColors colors) =>
      Container(height: 1, color: colors.glassBorder);

  Widget _logoutButton(ThemeColors colors, AppLocalizations t) {
    return GestureDetector(
      onTap: _logOut,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Text(
          t.logout,
          style: TextStyle(
            color: colors.text,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _messageCard(String title, String subtitle, ThemeColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
