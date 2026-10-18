import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../theme/picker_theme.dart';
import '../services/event_service.dart';
import '../services/task_service.dart';
import '../services/data_events.dart';
import '../widgets/schedule_item_sheet.dart';
import '../widgets/zenda_toast.dart';
import 'event_form_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final EventService eventService = EventService();
  final TaskService taskService = TaskService();
  late DateTime _selected;
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _items = [];
  List<dynamic> _overdue = [];

  static const int _basePage = 10000;
  late final DateTime _baseWeekStart;
  late final PageController _weekController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _baseWeekStart = _weekStartOf(_selected);
    _weekController = PageController(initialPage: _basePage);
    dataVersion.addListener(_onDataChanged);
    _load(showLoader: false);
  }

  @override
  void dispose() {
    dataVersion.removeListener(_onDataChanged);
    _weekController.dispose();
    super.dispose();
  }

  void _onDataChanged() => _load(showLoader: false);

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get _isToday => _selected == _today;

  Future<void> _load({bool showLoader = true}) async {
    final day = _selected;
    final includeOverdue = _isToday;
    if (showLoader) setState(() => _isLoading = true);
    final results = await Future.wait<List<dynamic>?>([
      eventService.getByDate(day),
      includeOverdue ? taskService.getOverdue(day) : Future.value(<dynamic>[]),
    ]);
    if (!mounted || day != _selected) return;
    setState(() {
      _isLoading = false;
      _hasError = results[0] == null;
      _items = results[0] ?? [];
      _overdue = results[1] ?? [];
    });
  }

  void _selectDay(DateTime day) {
    if (day == _selected) return;
    setState(() => _selected = day);
    final page = _pageFor(day);
    if (_weekController.hasClients && _weekController.page?.round() != page) {
      _weekController.jumpToPage(page);
    }
    _load();
  }

  DateTime _weekStartOf(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  DateTime _weekStartForPage(int page) => DateTime(
    _baseWeekStart.year,
    _baseWeekStart.month,
    _baseWeekStart.day + (page - _basePage) * 7,
  );

  int _pageFor(DateTime day) {
    final start = _weekStartOf(day);
    final diff = DateTime.utc(start.year, start.month, start.day)
        .difference(
          DateTime.utc(
            _baseWeekStart.year,
            _baseWeekStart.month,
            _baseWeekStart.day,
          ),
        )
        .inDays;
    return _basePage + diff ~/ 7;
  }

  void _onWeekChanged(int page) {
    final start = _weekStartForPage(page);
    _selectDay(
      DateTime(start.year, start.month, start.day + (_selected.weekday - 1)),
    );
  }

  String _subtitleText(AppLocalizations t) {
    if (_isLoading || _hasError) return '';
    final count = _items.length;
    final base = count == 0
        ? (_isToday ? t.calendarEmptyToday : t.calendarEmptyDay)
        : (_isToday ? t.calendarCountToday(count) : t.calendarCountDay(count));
    return _overdue.isEmpty
        ? base
        : '$base · ${t.calendarOverdueCount(_overdue.length)}';
  }

  DateTime? _parseDueDate(dynamic value) {
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

  String _timeText(dynamic item, AppLocalizations t) {
    final start = _formatTime(item['startTime']);
    final end = _formatTime(item['endTime']);
    if (start.isEmpty) return t.calendarAllDay;
    return end.isEmpty ? start : '$start — $end';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: zendaPickerTheme,
    );
    if (picked != null)
      _selectDay(DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _openForm() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EventFormPage(initialDate: _selected)),
    );
  }

  Future<void> _openItem(dynamic item, DateTime date) async {
    await showScheduleItemSheet(context, Map<String, dynamic>.from(item), date);
  }

  Future<void> _completeTask(dynamic item) async {
    if (item['done'] == true) return;
    final t = AppLocalizations.of(context);
    setState(() => item['done'] = true);
    HapticFeedback.selectionClick();
    final ok = await taskService.complete(item['id']);
    if (!mounted) return;
    if (!ok) {
      setState(() => item['done'] = false);
      if (taskService.lastError != null) {
        showZendaToast(
          context,
          t.taskCompleteError,
          subtitle: taskService.lastError,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: currentTheme,
      builder: (context, theme, _) {
        final colors = appThemes[theme]!;
        final label = TextStyle(
          color: colors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        );
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
                const SizedBox(height: 16),
                _weekStrip(colors),
                const SizedBox(height: 18),
                if (!_isLoading && !_hasError && _overdue.isNotEmpty) ...[
                  Text(
                    t.sectionOverdue,
                    style: label.copyWith(color: colors.danger),
                  ),
                  const SizedBox(height: 10),
                  for (final item in _overdue)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _overdueItem(item, colors, t),
                    ),
                  const SizedBox(height: 10),
                ],
                Text(t.sectionSchedule, style: label),
                const SizedBox(height: 14),
                ..._schedule(colors, t),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(ThemeColors colors, AppLocalizations t) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickDate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatWeekdayDayMonth(_selected),
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitleText(t),
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: _openForm,
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

  Widget _weekStrip(ThemeColors colors) {
    return SizedBox(
      height: 52,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: PageView.builder(
          controller: _weekController,
          onPageChanged: _onWeekChanged,
          itemBuilder: (context, page) =>
              _weekRow(_weekStartForPage(page), colors),
        ),
      ),
    );
  }

  Widget _weekRow(DateTime start, ThemeColors colors) {
    return Row(
      children: List.generate(7, (i) {
        final day = DateTime(start.year, start.month, start.day + i);
        final selected = day == _selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: i == 0 ? 0 : 4,
              end: i == 6 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => _selectDay(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? colors.accent : colors.glassBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? colors.accent : colors.glassBorder,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formatWeekdayCompact(day),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: selected ? colors.onAccent : colors.textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: selected ? colors.onAccent : colors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _checkCircle(dynamic item, ThemeColors colors) {
    final done = item['done'] == true;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: done ? null : () => _completeTask(item),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 10, top: 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? colors.accent : Colors.transparent,
            border: done ? null : Border.all(color: colors.accent, width: 2),
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
    );
  }

  Widget _timelineDot(Color color, ThemeColors colors) {
    return SizedBox(
      width: 24,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 11, start: 5),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: colors.bgA, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _overdueItem(dynamic item, ThemeColors colors, AppLocalizations t) {
    final dueDate = _parseDueDate(item['dueDate']) ?? _today;
    final days = _today.difference(dueDate).inDays;
    final projectName = item['projectName'];
    final time = _formatTime(item['startTime']);
    final dateText =
        '${formatDayMonth(dueDate)}${time.isEmpty ? '' : ', $time'}';
    return GestureDetector(
      onTap: () => _openItem(item, dueDate),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _timelineDot(colors.danger, colors),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(14, 11, 16, 12),
              decoration: BoxDecoration(
                color: colors.glassBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.danger.withOpacity(0.35)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _checkCircle(item, colors),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] ?? '',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.5),
                              child: Text(
                                dateText,
                                style: TextStyle(
                                  color: colors.danger,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.5),
                        Text(
                          projectName != null
                              ? '${t.overdueDays(days)} · $projectName'
                              : t.overdueDays(days),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.danger,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _schedule(ThemeColors colors, AppLocalizations t) {
    if (_isLoading) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 40),
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
      return [_messageCard(t.calendarLoadError, t.pullToRetry, colors)];
    }
    if (_items.isEmpty) {
      return [_messageCard(t.calendarFreeDay, t.calendarFreeDayHint, colors)];
    }
    return [
      Stack(
        children: [
          PositionedDirectional(
            start: 9.25,
            top: 0,
            bottom: 8,
            child: Container(
              width: 1.5,
              color: colors.accent.withOpacity(0.25),
            ),
          ),
          Column(
            children: [
              for (var i = 0; i < _items.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == _items.length - 1 ? 0 : 18,
                  ),
                  child: _timelineItem(_items[i], colors, t),
                ),
            ],
          ),
        ],
      ),
    ];
  }

  Widget _timelineItem(dynamic item, ThemeColors colors, AppLocalizations t) {
    final isTask = item['type'] == 'task';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timelineDot(isTask ? colors.accent2 : colors.accent, colors),
        Expanded(
          child: GestureDetector(
            onTap: () => _openItem(item, _selected),
            child: _itemCard(item, isTask, colors, t),
          ),
        ),
      ],
    );
  }

  Widget _itemCard(
    dynamic item,
    bool isTask,
    ThemeColors colors,
    AppLocalizations t,
  ) {
    final done = isTask && item['done'] == true;
    final comment = (item['comment'] ?? '').toString().trim();
    final address = (item['address'] ?? '').toString().trim();
    final List<dynamic> attachments = item['attachments'] ?? [];
    final muted = TextStyle(color: colors.textMuted, fontSize: 10.5);
    return AnimatedOpacity(
      opacity: done ? 0.55 : 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(isTask ? 14 : 16, 11, 16, 12),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isTask) _checkCircle(item, colors),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'] ?? '',
                          style: TextStyle(
                            color: done ? colors.textMuted : colors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: colors.textMuted,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.5),
                        child: Text(
                          _timeText(item, t),
                          style: TextStyle(
                            color: done ? colors.textMuted : colors.accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isTask) ...[
                    const SizedBox(height: 2.5),
                    Text(
                      item['projectName'] != null
                          ? t.calendarTaskWithProject(item['projectName'])
                          : t.calendarTask,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: 2.5),
                    Text(
                      t.commentPrefix(comment),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 2),
                          child: SvgPicture.asset(
                            'assets/icons/pin.svg',
                            width: 8,
                            height: 11,
                            colorFilter: ColorFilter.mode(
                              colors.textMuted,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: attachments
                          .map<Widget>((a) => _chip(a, colors))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(dynamic attachment, ThemeColors colors) {
    final int? typeId = attachment['typeId'];
    final Widget icon;
    if (typeId == 1) {
      icon = SvgPicture.asset(
        'assets/icons/play.svg',
        height: 10,
        colorFilter: ColorFilter.mode(colors.text, BlendMode.srcIn),
      );
    } else if (typeId == 4) {
      icon = Icon(Icons.link_rounded, size: 14, color: colors.text);
    } else {
      icon = SvgPicture.asset(
        'assets/icons/file.svg',
        height: 12,
        colorFilter: ColorFilter.mode(colors.text, BlendMode.srcIn),
      );
    }
    return Container(
      height: 24,
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsetsDirectional.only(start: 11, end: 10),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.accent.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              attachment['label'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.text,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
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
