import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../theme/themed_background.dart';
import '../theme/picker_theme.dart';
import '../widgets/zenda_text_field.dart';
import '../widgets/zenda_toast.dart';
import '../services/event_service.dart';

class EventFormPage extends StatefulWidget {
  final DateTime initialDate;
  final Map<String, dynamic>? existing;

  const EventFormPage({super.key, required this.initialDate, this.existing});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final EventService eventService = EventService();
  late DateTime _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  bool _isLoading = false;
  String? _titleError;
  String? _startError;
  String? _endError;
  int _shakeTick = 0;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    final existing = widget.existing;
    if (existing != null) {
      titleController.text = existing['title'] ?? '';
      addressController.text = existing['address'] ?? '';
      commentController.text = existing['comment'] ?? '';
      _start = _parseTime(existing['startTime']);
      _end = _parseTime(existing['endTime']);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    addressController.dispose();
    commentController.dispose();
    super.dispose();
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

  String _timeText(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _timeParam(TimeOfDay t) => '${_timeText(t)}:00';

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: zendaPickerTheme,
    );
    if (picked != null)
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart
        ? (_start ?? TimeOfDay.now())
        : (_end ?? _start ?? TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: zendaPickerTheme,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        _startError = null;
      } else {
        _end = picked;
      }
      _endError = null;
    });
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _titleError = titleController.text.trim().isEmpty
          ? t.fieldNameRequired
          : null;
      _startError = _start == null && _end != null ? t.startTimeRequired : null;
      _endError =
          _start != null && _end != null && _minutes(_end!) <= _minutes(_start!)
          ? t.endAfterStart
          : null;
      _shakeTick++;
    });
    if (_titleError != null || _startError != null || _endError != null) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final title = titleController.text.trim();
    final address = addressController.text.trim();
    final comment = commentController.text.trim();
    final startTime = _start == null ? null : _timeParam(_start!);
    final endTime = _end == null ? null : _timeParam(_end!);

    final success = _isEdit
        ? await eventService.update(
            widget.existing!['id'],
            title: title,
            date: _date,
            startTime: startTime,
            endTime: endTime,
            address: address.isEmpty ? null : address,
            comment: comment.isEmpty ? null : comment,
          )
        : await eventService.create(
            title: title,
            date: _date,
            startTime: startTime,
            endTime: endTime,
            address: address.isEmpty ? null : address,
            comment: comment.isEmpty ? null : comment,
          );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      showZendaToast(
        context,
        _isEdit ? t.eventUpdated : t.eventCreated,
        type: ZendaToastType.success,
      );
      Navigator.pop(context, true);
    } else if (eventService.lastError != null) {
      showZendaToast(
        context,
        _isEdit ? t.eventSaveError : t.eventCreateError,
        subtitle: eventService.lastError,
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
                          child: Text(
                            _isEdit
                                ? t.eventFormEditTitle
                                : t.eventFormNewTitle,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
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
                          _label(t.fieldName, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: titleController,
                            hint: t.eventTitleHint,
                            colors: colors,
                            errorText: _titleError,
                            shakeTick: _shakeTick,
                            onChanged: (_) {
                              if (_titleError != null)
                                setState(() => _titleError = null);
                            },
                          ),
                          const SizedBox(height: 14),
                          _label(t.fieldDate, colors),
                          const SizedBox(height: 8),
                          _pickerField(
                            text: formatWeekdayDayMonth(_date),
                            placeholder: false,
                            onTap: _pickDate,
                            colors: colors,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _label(t.fieldStart, colors),
                                    const SizedBox(height: 8),
                                    _pickerField(
                                      text: _start == null
                                          ? t.calendarAllDay
                                          : _timeText(_start!),
                                      placeholder: _start == null,
                                      onTap: () => _pickTime(true),
                                      onClear: () => setState(() {
                                        _start = null;
                                        _end = null;
                                        _startError = null;
                                        _endError = null;
                                      }),
                                      error: _startError,
                                      colors: colors,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    _label(t.fieldEnd, colors),
                                    const SizedBox(height: 8),
                                    _pickerField(
                                      text: _end == null
                                          ? '--:--'
                                          : _timeText(_end!),
                                      placeholder: _end == null,
                                      onTap: () => _pickTime(false),
                                      onClear: () => setState(() {
                                        _end = null;
                                        _endError = null;
                                      }),
                                      error: _endError,
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
