import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../services/project_service.dart';
import '../services/data_events.dart';
import '../widgets/zenda_toast.dart';

class ArchiveView extends StatefulWidget {
  final VoidCallback onBack;

  const ArchiveView({super.key, required this.onBack});

  @override
  State<ArchiveView> createState() => _ArchiveViewState();
}

class _ArchiveViewState extends State<ArchiveView> {
  final ProjectService projectService = ProjectService();
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _projects = [];
  final Set<int> _restoring = {};

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
    final projects = await projectService.getArchive();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = projects == null;
      if (projects != null) _projects = projects;
    });
  }

  String _subtitle(AppLocalizations t) {
    if (_isLoading || _hasError) return '';
    if (_projects.isEmpty) return t.archiveEmptySubtitle;
    return t.archiveCount(_projects.length);
  }

  String _completedText(dynamic value, AppLocalizations t) {
    final date = value == null
        ? null
        : DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return t.archiveCompleted;
    return t.archiveCompletedOn(formatDayMonth(date));
  }

  Future<void> _restore(dynamic project) async {
    final t = AppLocalizations.of(context);
    final int id = project['id'];
    setState(() => _restoring.add(id));
    final ok = await projectService.restore(id);
    if (!mounted) return;
    setState(() => _restoring.remove(id));
    if (ok) {
      showZendaToast(
        context,
        t.projectRestored,
        subtitle: project['name'],
        type: ZendaToastType.success,
      );
    } else if (projectService.lastError != null) {
      showZendaToast(
        context,
        t.restoreError,
        subtitle: projectService.lastError,
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onBack,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 12, 6),
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
                t.archiveTitle,
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
      return [_messageCard(t.archiveLoadError, t.pullToRetry, colors)];
    }
    if (_projects.isEmpty) {
      return [_messageCard(t.archiveEmptyTitle, t.archiveEmptyHint, colors)];
    }
    return [
      for (final project in _projects) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 2),
                  Text(
                    _completedText(project['completedAt'], t),
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _restoreButton(project, colors, t),
          ],
        ),
        const SizedBox(height: 6),
        _tasksCard(project, colors, t),
        const SizedBox(height: 20),
      ],
    ];
  }

  Widget _restoreButton(
    dynamic project,
    ThemeColors colors,
    AppLocalizations t,
  ) {
    final busy = _restoring.contains(project['id']);
    return GestureDetector(
      onTap: busy ? null : () => _restore(project),
      child: AnimatedOpacity(
        opacity: busy ? 0.5 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: colors.glassBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/restore.svg',
                height: 10,
                colorFilter: ColorFilter.mode(colors.accent, BlendMode.srcIn),
              ),
              const SizedBox(width: 5),
              Text(
                t.restore,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tasksCard(dynamic project, ThemeColors colors, AppLocalizations t) {
    final List<dynamic> tasks = project['tasks'] ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.glassBorder),
      ),
      child: tasks.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                t.archiveNoTasks,
                style: TextStyle(color: colors.textMuted, fontSize: 12.5),
              ),
            )
          : Column(
              children: tasks.map<Widget>((task) {
                return SizedBox(
                  height: 34,
                  child: Row(
                    children: [
                      const SizedBox(width: 9),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/check.svg',
                            width: 7,
                            colorFilter: ColorFilter.mode(
                              colors.onAccent,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task['title'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              }).toList(),
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
