import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../theme/themed_background.dart';
import '../theme/picker_theme.dart';
import '../widgets/zenda_text_field.dart';
import '../widgets/zenda_toast.dart';
import '../services/task_service.dart';

class TaskFormPage extends StatefulWidget {
  final Map<String, dynamic>? task;
  final DateTime? initialDate;
  final List<dynamic> projects;
  final int? initialProjectId;

  const TaskFormPage({
    super.key,
    this.task,
    this.initialDate,
    this.projects = const [],
    this.initialProjectId,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TaskService taskService = TaskService();
  int? _projectId;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isLoading = false;
  String? _projectError;
  String? _titleError;
  String? _timeError;
  int _shakeTick = 0;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      titleController.text = task['title'] ?? '';
      addressController.text = task['address'] ?? '';
      commentController.text = task['comment'] ?? '';
      _date = _parseDate(task['dueDate']) ?? widget.initialDate;
      _time = _parseTime(task['dueTime'] ?? task['startTime']);
    } else {
      _date = widget.initialDate;
      _projectId =
          widget.initialProjectId ??
          (widget.projects.length == 1
              ? widget.projects.first['id'] as int
              : null);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    addressController.dispose();
    commentController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString())?.toLocal();
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  TimeOfDay? _parseTime(dynamic value) {
    if (value == null) return null;
    final parts = value.toString().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String? get _projectName {
    for (final p in widget.projects) {
      if (p['id'] == _projectId) return p['name'];
    }
    return null;
  }

  String _timeText(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickProject(ThemeColors colors) async {
    final t = AppLocalizations.of(context);
    final id = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          16 + MediaQuery.of(sheetContext).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: colors.bgA,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: colors.glassBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                t.chooseProject,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.projects.map<Widget>((p) {
                  final selected = p['id'] == _projectId;
                  return GestureDetector(
                    onTap: () => Navigator.pop(sheetContext, p['id'] as int),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: colors.glassBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? colors.accent : colors.glassBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              p['name'] ?? '',
                              style: TextStyle(
                                color: selected ? colors.accent : colors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: colors.accent,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
    if (id != null) {
      setState(() {
        _projectId = id;
        _projectError = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: zendaPickerTheme,
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day);
        _timeError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: zendaPickerTheme,
    );
    if (picked != null) {
      setState(() {
        _time = picked;
        _timeError = null;
      });
    }
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _projectError = !_isEdit && _projectId == null ? t.chooseProject : null;
      _titleError = titleController.text.trim().isEmpty
          ? t.fieldNameRequired
          : null;
      _timeError = _time != null && _date == null ? t.setDeadlineFirst : null;
      _shakeTick++;
    });
    if (_projectError != null || _titleError != null || _timeError != null) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final title = titleController.text.trim();
    final address = addressController.text.trim();
    final comment = commentController.text.trim();
    final dueTime = _time == null ? null : '${_timeText(_time!)}:00';

    final success = _isEdit
        ? await taskService.update(
            widget.task!['id'],
            title: title,
            comment: comment.isEmpty ? null : comment,
            address: address.isEmpty ? null : address,
            dueDate: _date,
            dueTime: dueTime,
          )
        : await taskService.create(
            projectId: _projectId!,
            title: title,
            comment: comment.isEmpty ? null : comment,
            address: address.isEmpty ? null : address,
            dueDate: _date,
            dueTime: dueTime,
          );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      showZendaToast(
        context,
        _isEdit ? t.taskUpdated : t.taskCreated,
        type: ZendaToastType.success,
      );
      Navigator.pop(context, true);
    } else if (taskService.lastError != null) {
      showZendaToast(
        context,
        _isEdit ? t.taskSaveError : t.taskCreateError,
        subtitle: taskService.lastError,
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
        final editProjectName = widget.task?['projectName'];
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 24, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colors.text,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEdit ? t.taskFormEditTitle : t.taskNewTitle,
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_isEdit && editProjectName != null)
                                Text(
                                  t.taskFormProject(editProjectName),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
                      child: Column(
                        children: [
                          if (!_isEdit) ...[
                            _label(t.fieldProject, colors),
                            const SizedBox(height: 8),
                            _pickerField(
                              text: _projectName ?? t.chooseProject,
                              placeholder: _projectName == null,
                              onTap: () => _pickProject(colors),
                              error: _projectError,
                              colors: colors,
                            ),
                            const SizedBox(height: 14),
                          ],
                          _label(t.fieldName, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: titleController,
                            hint: t.taskTitleHint,
                            colors: colors,
                            errorText: _titleError,
                            shakeTick: _shakeTick,
                            onChanged: (_) {
                              if (_titleError != null)
                                setState(() => _titleError = null);
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _label(t.fieldDeadline, colors),
                                    const SizedBox(height: 8),
                                    _pickerField(
                                      text: _date == null
                                          ? t.deadlineNone
                                          : formatWeekdayDayMonth(_date!),
                                      placeholder: _date == null,
                                      onTap: _pickDate,
                                      onClear: () => setState(() {
                                        _date = null;
                                        _time = null;
                                        _timeError = null;
                                      }),
                                      colors: colors,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _label(t.fieldTime, colors),
                                    const SizedBox(height: 8),
                                    _pickerField(
                                      text: _time == null
                                          ? t.calendarAllDay
                                          : _timeText(_time!),
                                      placeholder: _time == null,
                                      onTap: _pickTime,
                                      onClear: () => setState(() {
                                        _time = null;
                                        _timeError = null;
                                      }),
                                      error: _timeError,
                                      colors: colors,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _label(t.fieldAddress, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: addressController,
                            hint: t.optionalHint,
                            colors: colors,
                          ),
                          const SizedBox(height: 14),
                          _label(t.fieldComment, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: commentController,
                            hint: t.optionalHint,
                            colors: colors,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 24),
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
                              onPressed: _isLoading ? null : _save,
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
                                      t.commonSave,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

  Widget _pickerField({
    required String text,
    required bool placeholder,
    required VoidCallback onTap,
    VoidCallback? onClear,
    String? error,
    required ThemeColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
            decoration: BoxDecoration(
              color: colors.cardBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: error != null
                  ? Border.all(color: colors.danger, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: placeholder
                          ? colors.textMuted.withOpacity(0.7)
                          : colors.text,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (!placeholder && onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6, start: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colors.danger, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    error,
                    style: TextStyle(color: colors.danger, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
