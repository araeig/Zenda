import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/project_service.dart';
import '../services/data_events.dart';
import '../services/reminder_service.dart';
import '../widgets/progress_ring.dart';
import 'project_page.dart';

enum ProjectSort { deadline, newest, oldest }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final ProjectService projectService = ProjectService();
  bool _isLoading = true;
  bool _hasError = false;
  String? _firstName;
  List<dynamic> _urgent = [];
  List<dynamic> _others = [];
  ProjectSort _sort = ProjectSort.deadline;

  static const String _sortKey = 'homeProjectSort';

  @override
  void initState() {
    super.initState();
    dataVersion.addListener(_load);
    dataVersion.addListener(_syncReminders);
    _loadSort();
    _load();
    _initReminders();
  }

  @override
  void dispose() {
    dataVersion.removeListener(_load);
    dataVersion.removeListener(_syncReminders);
    super.dispose();
  }

  void _syncReminders() => ReminderService.sync();

  Future<void> _initReminders() async {
    if (!ReminderService.supported) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(ReminderService.enabledKey) ?? true) {
      await ReminderService.requestPermission();
    }
    await ReminderService.sync();
  }

  Future<void> _loadSort() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_sortKey) ?? 0;
    if (!mounted || index < 0 || index >= ProjectSort.values.length) return;
    setState(() => _sort = ProjectSort.values[index]);
  }

  Future<void> _setSort(ProjectSort sort) async {
    setState(() => _sort = sort);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortKey, sort.index);
  }

  void _openProject(dynamic p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectPage(projectId: p['id'], initialName: p['name']),
      ),
    );
  }

  Future<void> _load() async {
    final results = await Future.wait([
      authService.getMe(),
      projectService.getHome(),
    ]);
    if (!mounted) return;
    final me = results[0];
    final home = results[1];
    setState(() {
      _isLoading = false;
      _hasError = home == null;
      if (me != null) _firstName = me['firstName'];
      if (home != null) {
        _urgent = home['urgent'] ?? [];
        _others = home['others'] ?? [];
      }
    });
  }

  DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

  int _daysFromToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(date.year, date.month, date.day).difference(today).inDays;
  }

  bool _isOverdue(dynamic value) {
    final date = _parseDate(value);
    return date != null && _daysFromToday(date) < 0;
  }

  String _deadlineText(dynamic value, AppLocalizations t) {
    final date = _parseDate(value);
    if (date == null) return t.deadlineNone;
    final days = _daysFromToday(date);
    if (days < 0) return t.overdueDays(-days);
    if (days == 0) return t.deadlineToday;
    if (days == 1) return t.deadlineTomorrow;
    return t.deadlineDate(formatDayMonth(date));
  }

  String _greeting(AppLocalizations t) {
    final hour = DateTime.now().hour;
    final String part;
    if (hour >= 5 && hour < 12) {
      part = t.greetingMorning;
    } else if (hour >= 12 && hour < 18) {
      part = t.greetingAfternoon;
    } else if (hour >= 18 && hour < 23) {
      part = t.greetingEvening;
    } else {
      part = t.greetingNight;
    }
    final name = _firstName;
    return name == null ? part : t.greetingWithName(part, name);
  }

  int _compareCreated(dynamic a, dynamic b) {
    final ca = _parseDate(a['createdAt']);
    final cb = _parseDate(b['createdAt']);
    if (ca != null && cb != null) return ca.compareTo(cb);
    return (a['id'] as int).compareTo(b['id'] as int);
  }

  List<dynamic> get _sortedOthers {
    final list = List<dynamic>.from(_others);
    switch (_sort) {
      case ProjectSort.deadline:
        list.sort((a, b) {
          final da = _parseDate(a['deadline']);
          final db = _parseDate(b['deadline']);
          if (da == null && db == null) return _compareCreated(a, b);
          if (da == null) return 1;
          if (db == null) return -1;
          final byDeadline = da.compareTo(db);
          return byDeadline != 0 ? byDeadline : _compareCreated(a, b);
        });
        break;
      case ProjectSort.newest:
        list.sort((a, b) => _compareCreated(b, a));
        break;
      case ProjectSort.oldest:
        list.sort((a, b) => _compareCreated(a, b));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
              padding: const EdgeInsets.only(top: 28, bottom: 120),
              children: [
                _pad(
                  Text(
                    _greeting(t),
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                _pad(
                  Text(
                    formatWeekdayDayMonth(DateTime.now()),
                    style: TextStyle(color: colors.textMuted, fontSize: 12.5),
                  ),
                ),
                const SizedBox(height: 16),
                ..._content(colors, t),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _content(ThemeColors colors, AppLocalizations t) {
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
    if (_hasError) {
      return [_pad(_messageCard(t.projectsLoadError, t.pullToRetry, colors))];
    }
    if (_urgent.isEmpty && _others.isEmpty) {
      return [
        _pad(_messageCard(t.projectsEmptyTitle, t.projectsEmptyHome, colors)),
      ];
    }
    final sorted = _sortedOthers;
    return [
      if (_urgent.isNotEmpty) ...[
        _pad(_sectionLabel(t.sectionUrgent, colors)),
        const SizedBox(height: 8),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _urgent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _openProject(_urgent[index]),
              child: _urgentCard(_urgent[index], index, colors, t),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      if (sorted.isNotEmpty) ...[
        _pad(
          Row(
            children: [
              _sectionLabel(t.sectionOtherProjects, colors),
              const Spacer(),
              _sortChip(colors, t),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < sorted.length; i++)
          _pad(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _openProject(sorted[i]),
                child: _projectRow(sorted[i], i, colors, t),
              ),
            ),
          ),
      ],
    ];
  }

  Widget _pad(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: child,
  );

  Widget _sectionLabel(String text, ThemeColors colors) => Text(
    text,
    style: TextStyle(
      color: colors.textMuted,
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
    ),
  );

  BoxDecoration _glass(ThemeColors colors, double radius) => BoxDecoration(
    color: colors.glassBg,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: colors.glassBorder),
  );

  Widget _clock(Color color, double size) => SvgPicture.asset(
    'assets/icons/clock.svg',
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );

  Widget _urgentCard(
    dynamic p,
    int index,
    ThemeColors colors,
    AppLocalizations t,
  ) {
    final ringColor = index.isEven ? colors.accent : colors.accent2;
    final deadlineColor = _isOverdue(p['deadline'])
        ? colors.danger
        : colors.accent;
    return Container(
      width: 158,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: _glass(colors, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p['name'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.text,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              _clock(deadlineColor, 9),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  _deadlineText(p['deadline'], t),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: deadlineColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              ProgressRing(
                percent: p['progressPercent'] ?? 0,
                color: ringColor,
                trackColor: colors.ringTrack,
                textColor: colors.text,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stat(p['total'], t.statTotal, colors),
                    _stat(p['done'], t.statDone, colors),
                    _stat(p['remaining'], t.statLeft, colors),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(dynamic value, String word, ThemeColors colors) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '${value ?? 0} ',
          style: TextStyle(color: colors.text),
        ),
        TextSpan(
          text: word,
          style: TextStyle(color: colors.textMuted),
        ),
      ],
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.4,
    ),
  );

  Widget _projectRow(
    dynamic p,
    int index,
    ThemeColors colors,
    AppLocalizations t,
  ) {
    final barColor = index.isEven ? colors.accent : colors.accent2;
    final int percent = p['progressPercent'] ?? 0;
    final int total = p['total'] ?? 0;
    final int done = p['done'] ?? 0;
    final overdue = _isOverdue(p['deadline']);
    final tasksText = total == 0
        ? t.tasksNone
        : t.tasksDoneOfTotal(done, total);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
      decoration: _glass(colors, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percent%',
                style: TextStyle(
                  color: barColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              _clock(overdue ? colors.danger : colors.textMuted, 10),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_deadlineText(p['deadline'], t)} · $tasksText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: overdue ? colors.danger : colors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _progressBar(percent, barColor, colors.ringTrack),
        ],
      ),
    );
  }

  Widget _progressBar(int percent, Color color, Color track) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            Container(color: track),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent / 100),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(ThemeColors colors, AppLocalizations t) {
    final chipLabels = {
      ProjectSort.deadline: t.sortByDeadline,
      ProjectSort.newest: t.sortNewest,
      ProjectSort.oldest: t.sortOldest,
    };
    final menuLabels = {
      ProjectSort.deadline: t.sortByDeadlineFull,
      ProjectSort.newest: t.sortNewest,
      ProjectSort.oldest: t.sortOldest,
    };
    return PopupMenuButton<ProjectSort>(
      initialValue: _sort,
      onSelected: _setSort,
      tooltip: '',
      color: colors.bgA,
      elevation: 6,
      offset: const Offset(0, 34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.glassBorder),
      ),
      itemBuilder: (context) => ProjectSort.values
          .map(
            (s) => PopupMenuItem<ProjectSort>(
              value: s,
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      menuLabels[s]!,
                      style: TextStyle(
                        color: s == _sort ? colors.accent : colors.text,
                        fontSize: 13,
                        fontWeight: s == _sort
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (s == _sort)
                    Icon(Icons.check_rounded, size: 16, color: colors.accent),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 8, 5),
        decoration: _glass(colors, 999),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              chipLabels[_sort]!,
              style: TextStyle(
                color: colors.accent,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: colors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageCard(String title, String subtitle, ThemeColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: _glass(colors, 20),
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
