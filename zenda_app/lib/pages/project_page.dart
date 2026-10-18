import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../theme/themed_background.dart';
import '../services/task_service.dart';
import '../services/data_events.dart';
import '../widgets/progress_ring.dart';
import '../widgets/schedule_item_sheet.dart';
import '../widgets/zenda_toast.dart';
import 'task_form_page.dart';
import 'project_form_page.dart';

class ProjectPage extends StatefulWidget {
  final int projectId;
  final String? initialName;

  const ProjectPage({super.key, required this.projectId, this.initialName});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final TaskService taskService = TaskService();
  Map<String, dynamic>? _project;
  bool _isLoading = true;
  bool _hasError = false;
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    dataVersion.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    dataVersion.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final projects = await taskService.getAll();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = projects == null;
      if (projects != null) {
        Map<String, dynamic>? found;
        for (final p in projects) {
          if (p['id'] == widget.projectId) {
            found = Map<String, dynamic>.from(p);
            break;
          }
        }
        _project = found;
        _missing = found == null;
      }
    });
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString())?.toLocal();
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String _formatTime(dynamic value) {
    if (value == null) return '';
    final parts = value.toString().split(':');
    if (parts.length < 2) return value.toString();
    return '${parts[0].padLeft(2, '0')}:${parts[1]}';
  }

  bool get _projectOverdue {
    final date = _parseDate(_project?['deadline']);
    return date != null && date.isBefore(_today);
  }

  String _deadlineText(AppLocalizations t) {
    final date = _parseDate(_project?['deadline']);
    if (date == null) return t.deadlineNone;
    final days = date.difference(_today).inDays;
    if (days < 0) return t.overdueDays(-days);
    if (days == 0) return t.deadlineToday;
    if (days == 1) return t.deadlineTomorrow;
    return t.deadlineDate(formatDayMonth(date));
  }

  bool _isOverdue(dynamic task) {
    if (task['done'] == true) return false;
    final date = _parseDate(task['dueDate']);
    return date != null && date.isBefore(_today);
  }

  String _metaText(dynamic task, AppLocalizations t) {
    final date = _parseDate(task['dueDate']);
    if (date == null) return '';
    final days = date.difference(_today).inDays;
    final time = _formatTime(task['dueTime']);
    if (days == 0) return time.isEmpty ? t.taskMetaToday : time;
    if (days == -1) return t.taskMetaYesterday;
    if (days == 1)
      return time.isEmpty ? t.taskMetaTomorrow : t.taskMetaTomorrowAt(time);
    return formatShortWeekdayDate(date);
  }

  List<dynamic> get _tasks => (_project?['tasks'] as List?) ?? [];

  List<dynamic> get _sortedTasks {
    final List<dynamic> tasks = List.from(_tasks);
    tasks.sort((a, b) {
      final doneA = a['done'] == true;
      final doneB = b['done'] == true;
      if (doneA != doneB) return doneA ? 1 : -1;
      final da = _parseDate(a['dueDate']);
      final db = _parseDate(b['dueDate']);
      if (da == null && db == null)
        return (a['id'] as int).compareTo(b['id'] as int);
      if (da == null) return 1;
      if (db == null) return -1;
      final byDate = da.compareTo(db);
      if (byDate != 0) return byDate;
      return _formatTime(a['dueTime']).compareTo(_formatTime(b['dueTime']));
    });
    return tasks;
  }

  Future<void> _complete(dynamic task) async {
    if (task['done'] == true) return;
    final t = AppLocalizations.of(context);
    final lastOpen = _tasks.where((x) => x['done'] != true).length == 1;
    setState(() => task['done'] = true);
    HapticFeedback.selectionClick();
    final ok = await taskService.complete(task['id']);
    if (!mounted) return;
    if (!ok) {
      setState(() => task['done'] = false);
      if (taskService.lastError != null) {
        showZendaToast(
          context,
          t.taskCompleteError,
          subtitle: taskService.lastError,
        );
      }
      return;
    }
    if (lastOpen) {
      showZendaToast(
        context,
        t.projectFinishedTitle,
        subtitle: t.projectFinishedMoved,
        type: ZendaToastType.success,
      );
      Navigator.pop(context);
    }
  }

  Future<void> _openTask(dynamic task) async {
    final item = Map<String, dynamic>.from(task)
      ..['type'] = 'task'
      ..['startTime'] = task['dueTime']
      ..['projectName'] = _project?['name']
      ..['overdue'] = _isOverdue(task);
    await showScheduleItemSheet(context, item, _parseDate(task['dueDate']));
  }

  void _addTask() {
    final project = _project;
    if (project == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormPage(
          projects: [project],
          initialProjectId: widget.projectId,
        ),
      ),
    );
  }

  void _editProject() {
    final project = _project;
    if (project == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectFormPage(existing: project)),
    );
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
              child: RefreshIndicator(
                color: colors.accent,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    _header(colors, t),
                    const SizedBox(height: 18),
                    ..._content(colors, t),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(ThemeColors colors, AppLocalizations t) {
    final name = _project?['name'] ?? widget.initialName ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 12, 5),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: colors.text,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              if (_project != null) ...[
                const SizedBox(height: 2),
                Text(
                  _deadlineText(t),
                  style: TextStyle(
                    color: _projectOverdue ? colors.danger : colors.textMuted,
                    fontSize: 12,
                    fontWeight: _projectOverdue
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_project != null) ...[
          const SizedBox(width: 8),
          _pill(Icons.edit_outlined, t.projectEdit, _editProject, colors),
        ],
      ],
    );
  }

  Widget _pill(
    IconData icon,
    String text,
    VoidCallback onTap,
    ThemeColors colors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: colors.accent),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: colors.text,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(ThemeColors colors, AppLocalizations t) {
    if (_isLoading) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 60),
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
      return [_messageCard(t.projectLoadError, t.pullToRetry, colors)];
    }
    if (_missing) {
      return [
        _messageCard(t.projectFinishedTitle, t.projectFinishedArchived, colors),
      ];
    }
    final total = _tasks.length;
    final done = _tasks.where((x) => x['done'] == true).length;
    final percent = total == 0 ? 0 : (done * 100 / total).round();
    final tasks = _sortedTasks;
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          children: [
            ProgressRing(
              percent: percent,
              color: colors.accent,
              trackColor: colors.ringTrack,
              textColor: colors.text,
            ),
            const SizedBox(width: 16),
            _stat(total, t.statTotal, colors),
            _stat(done, t.statDone, colors),
            _stat(total - done, t.statLeft, colors),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Text(
            t.sectionTasks,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _pill(Icons.add_rounded, t.projectAddTask, _addTask, colors),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.glassBorder),
        ),
        child: tasks.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  t.projectNoTasks,
                  style: TextStyle(color: colors.textMuted, fontSize: 12.5),
                ),
              )
            : Column(
                children: [
                  for (var i = 0; i < tasks.length; i++) ...[
                    if (i > 0) Container(height: 1, color: colors.glassBorder),
                    _taskRow(tasks[i], colors, t),
                  ],
                ],
              ),
      ),
    ];
  }

  Widget _stat(int value, String label, ThemeColors colors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow(dynamic task, ThemeColors colors, AppLocalizations t) {
    final done = task['done'] == true;
    final overdue = _isOverdue(task);
    final meta = _metaText(task, t);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openTask(task),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _complete(task),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 12, 7, 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? colors.accent : Colors.transparent,
                    border: done
                        ? null
                        : Border.all(color: colors.accent, width: 2),
                  ),
                  child: done
                      ? Center(
                          child: SvgPicture.asset(
                            'assets/icons/check.svg',
                            width: 8,
                            colorFilter: ColorFilter.mode(
                              colors.onAccent,
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: Text(
                task['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: done ? colors.textMuted : colors.text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (meta.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                meta,
                style: TextStyle(
                  color: overdue ? colors.danger : colors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(width: 16),
          ],
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
