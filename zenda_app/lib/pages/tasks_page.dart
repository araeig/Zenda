import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../services/task_service.dart';
import '../services/data_events.dart';
import '../widgets/schedule_item_sheet.dart';
import '../widgets/zenda_toast.dart';
import 'task_form_page.dart';
import 'project_form_page.dart';
import 'archive_view.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskService taskService = TaskService();
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _projects = [];
  bool _showArchive = false;

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
      if (projects != null) _projects = projects;
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

  List<dynamic> _sortedTasks(dynamic project) {
    final List<dynamic> tasks = List.from(project['tasks'] ?? []);
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

  int get _activeCount => _projects.fold<int>(
    0,
    (sum, p) =>
        sum +
        ((p['tasks'] as List?) ?? []).where((x) => x['done'] != true).length,
  );

  int get _doneCount => _projects.fold<int>(
    0,
    (sum, p) =>
        sum +
        ((p['tasks'] as List?) ?? []).where((x) => x['done'] == true).length,
  );

  String _subtitle(AppLocalizations t) {
    if (_isLoading || _hasError) return '';
    return t.tasksSummary(_activeCount, _doneCount);
  }

  Future<void> _complete(dynamic task, dynamic project) async {
    if (task['done'] == true) return;
    final t = AppLocalizations.of(context);
    final List<dynamic> tasks = project['tasks'] ?? [];
    final lastOpen = tasks.where((x) => x['done'] != true).length == 1;
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
    }
  }

  Future<void> _openTask(dynamic task, dynamic project) async {
    final item = Map<String, dynamic>.from(task)
      ..['type'] = 'task'
      ..['startTime'] = task['dueTime']
      ..['projectName'] = project['name']
      ..['overdue'] = _isOverdue(task);
    await showScheduleItemSheet(context, item, _parseDate(task['dueDate']));
  }

  Future<void> _openCreateMenu(ThemeColors colors) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _createSheet(sheetContext, colors),
    );
    if (!mounted || choice == null) return;
    final t = AppLocalizations.of(context);
    if (choice == 'task') {
      if (_projects.isEmpty) {
        showZendaToast(
          context,
          t.createProjectFirst,
          subtitle: t.tasksLiveInProjects,
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TaskFormPage(projects: _projects)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProjectFormPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showArchive) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) setState(() => _showArchive = false);
        },
        child: ArchiveView(onBack: () => setState(() => _showArchive = false)),
      );
    }
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
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
              children: [
                _header(colors, t),
                const SizedBox(height: 14),
                ..._content(colors, t),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(ThemeColors colors, AppLocalizations t) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.tasksTitle,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _subtitle(t),
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _showArchive = true),
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
                SvgPicture.asset(
                  'assets/icons/archive.svg',
                  height: 10,
                  colorFilter: ColorFilter.mode(colors.accent, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                Text(
                  t.archiveTitle,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _openCreateMenu(colors),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.glassBg,
              shape: BoxShape.circle,
              border: Border.all(color: colors.glassBorder),
            ),
            child: Icon(Icons.add_rounded, color: colors.accent, size: 22),
          ),
        ),
      ],
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
      return [_messageCard(t.tasksLoadError, t.pullToRetry, colors)];
    }
    if (_projects.isEmpty) {
      return [_messageCard(t.projectsEmptyTitle, t.tasksEmptyHint, colors)];
    }
    return [
      for (final project in _projects) ...[
        Text(
          (project['name'] ?? '').toString().toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _projectCard(project, colors, t),
        const SizedBox(height: 18),
      ],
    ];
  }

  Widget _projectCard(dynamic project, ThemeColors colors, AppLocalizations t) {
    final tasks = _sortedTasks(project);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.glassBorder),
      ),
      child: tasks.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                t.tasksEmptyProject,
                style: TextStyle(color: colors.textMuted, fontSize: 12.5),
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  if (i > 0) Container(height: 1, color: colors.glassBorder),
                  _taskRow(tasks[i], project, colors, t),
                ],
              ],
            ),
    );
  }

  Widget _taskRow(
    dynamic task,
    dynamic project,
    ThemeColors colors,
    AppLocalizations t,
  ) {
    final done = task['done'] == true;
    final overdue = _isOverdue(task);
    final meta = _metaText(task, t);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openTask(task, project),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _complete(task, project),
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

  Widget _createSheet(BuildContext sheetContext, ThemeColors colors) {
    final t = AppLocalizations.of(sheetContext);
    Widget option(String value, IconData icon, String title, String subtitle) {
      return GestureDetector(
        onTap: () => Navigator.pop(sheetContext, value),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.glassBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: colors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        14 + MediaQuery.of(sheetContext).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.bgA,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: colors.glassBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          option(
            'task',
            Icons.check_circle_outline_rounded,
            t.taskNewTitle,
            t.createTaskSubtitle,
          ),
          option(
            'project',
            Icons.folder_open_rounded,
            t.projectFormNewTitle,
            t.createProjectSubtitle,
          ),
        ],
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
