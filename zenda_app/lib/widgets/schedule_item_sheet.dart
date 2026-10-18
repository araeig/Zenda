import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';
import '../services/attachment_service.dart';
import '../services/event_service.dart';
import '../services/task_service.dart';
import '../services/note_service.dart';
import '../pages/event_form_page.dart';
import '../pages/task_form_page.dart';
import '../pages/note_form_page.dart';
import 'zenda_toast.dart';

Future<bool?> showScheduleItemSheet(
  BuildContext context,
  Map<String, dynamic> item,
  DateTime? date,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ScheduleItemSheet(item: item, date: date),
  );
}

class ScheduleItemSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final DateTime? date;

  const ScheduleItemSheet({super.key, required this.item, this.date});

  @override
  State<ScheduleItemSheet> createState() => _ScheduleItemSheetState();
}

class _ScheduleItemSheetState extends State<ScheduleItemSheet> {
  final EventService eventService = EventService();
  final TaskService taskService = TaskService();
  final NoteService noteService = NoteService();
  final AttachmentService attachmentService = AttachmentService();
  bool _busy = false;
  bool _notesLoading = true;
  bool _attachmentsBusy = false;
  List<dynamic> _notes = [];
  late final List<dynamic> _attachments = List<dynamic>.from(
    widget.item['attachments'] ?? [],
  );

  static const int _maxFileSize = 20 * 1024 * 1024;

  bool get _isTask => widget.item['type'] == 'task';
  bool get _done => widget.item['done'] == true;
  bool get _isOverdue => widget.item['overdue'] == true;
  int get _itemId => widget.item['id'];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = _isTask
        ? await noteService.getFor(taskItemId: _itemId)
        : await noteService.getFor(eventId: _itemId);
    if (!mounted) return;
    setState(() {
      _notesLoading = false;
      if (notes != null) _notes = notes;
    });
  }

  Future<void> _openNote([Map<String, dynamic>? existing]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormPage(
          taskItemId: _isTask ? _itemId : null,
          eventId: _isTask ? null : _itemId,
          ownerTitle: widget.item['title'],
          ownerIsTask: _isTask,
          existing: existing,
        ),
      ),
    );
    if (changed == true && mounted) _loadNotes();
  }

  bool _isAutoTitle(String title, String content) {
    final base = title.endsWith('…')
        ? title.substring(0, title.length - 1).trimRight()
        : title.trim();
    return base.isNotEmpty && content.trim().startsWith(base);
  }

  Future<void> _openAttachment(dynamic attachment) async {
    final t = AppLocalizations.of(context);
    final url = (attachment['url'] ?? '').toString();
    final full = url.startsWith('/') ? '${ApiClient.baseUrl}$url' : url;
    final uri = Uri.tryParse(full);
    var opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('Open attachment error: $e');
      }
    }
    if (!opened && mounted) showZendaToast(context, t.attachmentOpenError);
  }

  Future<void> _addAttachment(ThemeColors colors) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _addChoiceSheet(sheetContext, colors),
    );
    if (!mounted || choice == null) return;
    if (choice == 'file') {
      await _pickFile();
    } else {
      await _addLink(colors);
    }
  }

  Future<void> _pickFile() async {
    final t = AppLocalizations.of(context);
    final XFile? file = await openFile();
    if (file == null || !mounted) return;

    final size = await file.length();
    if (!mounted) return;
    if (size > _maxFileSize) {
      showZendaToast(
        context,
        t.attachmentTooBig,
        subtitle: t.attachmentTooBigHint,
      );
      return;
    }

    setState(() => _attachmentsBusy = true);
    final bytes = await file.readAsBytes();
    final created = await attachmentService.uploadFile(
      bytes,
      file.name,
      taskItemId: _isTask ? _itemId : null,
      eventId: _isTask ? null : _itemId,
    );
    if (!mounted) return;
    setState(() {
      _attachmentsBusy = false;
      if (created != null) _attachments.add(created);
    });
    if (created != null) {
      showZendaToast(
        context,
        t.attachmentFileAdded,
        type: ZendaToastType.success,
      );
    } else if (attachmentService.lastError != null) {
      showZendaToast(
        context,
        t.attachmentUploadError,
        subtitle: attachmentService.lastError,
      );
    }
  }

  Future<void> _addLink(ThemeColors colors) async {
    final t = AppLocalizations.of(context);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _LinkDialog(colors: colors),
    );
    if (result == null || !mounted) return;

    final url = result['url'] ?? '';
    final label = result['label'] ?? '';

    setState(() => _attachmentsBusy = true);
    final created = await attachmentService.addLink(
      url,
      label: label.isEmpty ? null : label,
      taskItemId: _isTask ? _itemId : null,
      eventId: _isTask ? null : _itemId,
    );
    if (!mounted) return;
    setState(() {
      _attachmentsBusy = false;
      if (created != null) _attachments.add(created);
    });
    if (created != null) {
      showZendaToast(
        context,
        t.attachmentLinkAdded,
        type: ZendaToastType.success,
      );
    } else if (attachmentService.lastError != null) {
      showZendaToast(
        context,
        t.attachmentLinkError,
        subtitle: attachmentService.lastError,
      );
    }
  }

  Future<void> _deleteAttachment(dynamic attachment, ThemeColors colors) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.bgA,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          t.attachmentDeleteTitle,
          style: TextStyle(
            color: colors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          t.attachmentDeleteText(attachment['label'] ?? ''),
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              t.commonCancel,
              style: TextStyle(color: colors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              t.commonDelete,
              style: TextStyle(
                color: colors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _attachmentsBusy = true);
    final ok = await attachmentService.delete(attachment['id']);
    if (!mounted) return;
    setState(() {
      _attachmentsBusy = false;
      if (ok) _attachments.remove(attachment);
    });
    if (!ok && attachmentService.lastError != null) {
      showZendaToast(
        context,
        t.attachmentDeleteError,
        subtitle: attachmentService.lastError,
      );
    }
  }

  int get _overdueDays {
    final date = widget.date;
    if (date == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(DateTime(date.year, date.month, date.day)).inDays;
  }

  String _formatTime(dynamic value) {
    if (value == null) return '';
    final parts = value.toString().split(':');
    if (parts.length < 2) return value.toString();
    return '${parts[0].padLeft(2, '0')}:${parts[1]}';
  }

  String _whenText(AppLocalizations t) {
    final d = widget.date;
    if (d == null) return t.deadlineNone;
    final dateText = formatWeekdayDayMonth(d);
    final start = _formatTime(widget.item['startTime']);
    final end = _formatTime(widget.item['endTime']);
    if (start.isEmpty) return '$dateText · ${t.sheetAllDayLower}';
    return end.isEmpty ? '$dateText · $start' : '$dateText · $start — $end';
  }

  Future<void> _edit() async {
    final Widget page = _isTask
        ? TaskFormPage(task: widget.item, initialDate: widget.date)
        : EventFormPage(
            initialDate: widget.date ?? DateTime.now(),
            existing: widget.item,
          );
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (saved == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _complete() async {
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ok = await taskService.complete(_itemId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showZendaToast(context, t.taskCompleted, type: ZendaToastType.success);
      Navigator.pop(context, true);
    } else if (taskService.lastError != null) {
      showZendaToast(
        context,
        t.taskCompleteError,
        subtitle: taskService.lastError,
      );
    }
  }

  Future<void> _moveToToday() async {
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    final now = DateTime.now();
    final item = widget.item;
    final ok = await taskService.update(
      item['id'],
      title: item['title'] ?? '',
      comment: item['comment'],
      address: item['address'],
      dueDate: DateTime(now.year, now.month, now.day),
      dueTime: item['startTime']?.toString(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showZendaToast(context, t.movedToToday, type: ZendaToastType.success);
      Navigator.pop(context, true);
    } else if (taskService.lastError != null) {
      showZendaToast(context, t.moveError, subtitle: taskService.lastError);
    }
  }

  Future<void> _delete(ThemeColors colors) async {
    final t = AppLocalizations.of(context);
    final hasExtras = _notes.isNotEmpty || _attachments.isNotEmpty;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.bgA,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _isTask ? t.deleteTaskTitle : t.deleteEventTitle,
          style: TextStyle(
            color: colors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          hasExtras ? t.deleteWithExtras : t.deleteIrreversible,
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              t.commonCancel,
              style: TextStyle(color: colors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              t.commonDelete,
              style: TextStyle(
                color: colors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final ok = _isTask
        ? await taskService.delete(_itemId)
        : await eventService.delete(_itemId);
    if (!mounted) return;
    setState(() => _busy = false);
    final error = _isTask ? taskService.lastError : eventService.lastError;
    if (ok) {
      showZendaToast(
        context,
        _isTask ? t.taskDeleted : t.eventDeleted,
        type: ZendaToastType.success,
      );
      Navigator.pop(context, true);
    } else if (error != null) {
      showZendaToast(context, t.deleteError, subtitle: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = appThemes[currentTheme.value]!;
    final item = widget.item;
    final comment = (item['comment'] ?? '').toString().trim();
    final address = (item['address'] ?? '').toString().trim();
    final typeText = _isTask
        ? (item['projectName'] != null
              ? '${t.sheetTypeTask} · ${item['projectName'].toString().toUpperCase()}'
              : t.sheetTypeTask)
        : t.sheetTypeEvent;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colors.bgA,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: colors.glassBorder)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.of(context).padding.bottom,
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
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isTask ? colors.accent2 : colors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    typeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['title'] ?? '',
              style: TextStyle(
                color: _done ? colors.textMuted : colors.text,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                decoration: _done ? TextDecoration.lineThrough : null,
                decorationColor: colors.textMuted,
                decorationThickness: 2,
              ),
            ),
            if (_done) ...[
              const SizedBox(height: 4),
              Text(
                t.sheetDone,
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (_isOverdue) ...[
              const SizedBox(height: 4),
              Text(
                t.overdueDays(_overdueDays),
                style: TextStyle(
                  color: colors.danger,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _infoRow('assets/icons/clock.svg', _whenText(t), colors),
            if (address.isNotEmpty) ...[
              const SizedBox(height: 10),
              _infoRow('assets/icons/pin.svg', address, colors),
            ],
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.glassBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Text(
                  comment,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _attachmentsSection(colors, t),
            const SizedBox(height: 20),
            _notesSection(colors, t),
            const SizedBox(height: 24),
            if (_isTask && !_done) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _busy ? null : _complete,
                  child: Text(
                    t.markDone,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (_isOverdue) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.accent,
                    side: BorderSide(color: colors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _busy ? null : _moveToToday,
                  child: Text(
                    t.moveToToday,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.accent,
                        side: BorderSide(color: colors.accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _busy ? null : _edit,
                      child: Text(
                        t.projectEdit,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.danger,
                        side: BorderSide(color: colors.danger.withOpacity(0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _busy ? null : () => _delete(colors),
                      child: Text(
                        t.commonDelete,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    VoidCallback? onAdd,
    bool busy,
    ThemeColors colors,
    AppLocalizations t,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: busy ? null : onAdd,
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
                if (busy)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      color: colors.accent,
                      strokeWidth: 1.6,
                    ),
                  )
                else
                  Icon(Icons.add_rounded, size: 14, color: colors.accent),
                const SizedBox(width: 4),
                Text(
                  t.commonAdd,
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
      ],
    );
  }

  Widget _attachmentsSection(ThemeColors colors, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          t.sectionAttachments,
          () => _addAttachment(colors),
          _attachmentsBusy,
          colors,
          t,
        ),
        const SizedBox(height: 10),
        if (_attachments.isEmpty)
          Text(
            t.attachmentsEmpty,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          )
        else
          for (final attachment in _attachments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _attachmentRow(attachment, colors, t),
            ),
      ],
    );
  }

  String _typeName(dynamic typeId, AppLocalizations t) {
    switch (typeId) {
      case 1:
        return t.attachmentTypeVideo;
      case 2:
        return t.attachmentTypeDocument;
      case 4:
        return t.attachmentTypeLink;
      default:
        return t.attachmentTypeFile;
    }
  }

  Widget _attachmentIcon(dynamic attachment, Color color) {
    switch (attachment['typeId']) {
      case 1:
        return SvgPicture.asset(
          'assets/icons/play.svg',
          height: 11,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 4:
        return Icon(Icons.link_rounded, size: 17, color: color);
      default:
        return SvgPicture.asset(
          'assets/icons/file.svg',
          height: 13,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
    }
  }

  Widget _attachmentRow(
    dynamic attachment,
    ThemeColors colors,
    AppLocalizations t,
  ) {
    return GestureDetector(
      onTap: () => _openAttachment(attachment),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 4, 8),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              child: Center(child: _attachmentIcon(attachment, colors.accent)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment['label'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _typeName(attachment['typeId'], t),
                    style: TextStyle(color: colors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: _attachmentsBusy
                  ? null
                  : () => _deleteAttachment(attachment, colors),
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addChoiceSheet(BuildContext sheetContext, ThemeColors colors) {
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
            'file',
            Icons.attach_file_rounded,
            t.attachmentTypeFile,
            t.attachmentFileHint,
          ),
          option(
            'link',
            Icons.link_rounded,
            t.attachmentTypeLink,
            t.attachmentLinkHint,
          ),
        ],
      ),
    );
  }

  Widget _notesSection(ThemeColors colors, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(t.sectionNotes, () => _openNote(), false, colors, t),
        const SizedBox(height: 10),
        if (_notesLoading)
          SizedBox(
            height: 36,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: colors.accent,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else if (_notes.isEmpty)
          Text(
            t.notesEmpty,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          )
        else
          for (final note in _notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _noteCard(note, colors),
            ),
      ],
    );
  }

  Widget _noteCard(dynamic note, ThemeColors colors) {
    final title = (note['title'] ?? '').toString();
    final content = (note['content'] ?? '').toString();
    final auto = _isAutoTitle(title, content);
    return GestureDetector(
      onTap: () => _openNote(Map<String, dynamic>.from(note)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!auto) ...[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
            ],
            Text(
              content,
              maxLines: auto ? 4 : 3,
              overflow: TextOverflow.ellipsis,
              style: auto
                  ? TextStyle(color: colors.text, fontSize: 13, height: 1.4)
                  : TextStyle(
                      color: colors.textMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String icon, String text, ThemeColors colors) {
    return Row(
      children: [
        SizedBox(
          width: 14,
          child: SvgPicture.asset(
            icon,
            height: 12,
            colorFilter: ColorFilter.mode(colors.textMuted, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: colors.text, fontSize: 13)),
        ),
      ],
    );
  }
}

class _LinkDialog extends StatefulWidget {
  final ThemeColors colors;

  const _LinkDialog({required this.colors});

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _submit() {
    final url = _urlController.text.trim();
    if (url.isEmpty || !url.contains('.')) {
      setState(() => _error = AppLocalizations.of(context).linkDialogError);
      return;
    }
    Navigator.pop(context, {'url': url, 'label': _labelController.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = widget.colors;
    return AlertDialog(
      backgroundColor: colors.bgA,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        t.attachmentTypeLink,
        style: TextStyle(
          color: colors.text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field(_urlController, 'https://…', _error),
          const SizedBox(height: 10),
          _field(_labelController, t.linkDialogNameHint, null),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            t.commonCancel,
            style: TextStyle(color: colors.textMuted),
          ),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            t.commonAdd,
            style: TextStyle(color: colors.accent, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String hint, String? error) {
    final colors = widget.colors;
    return TextField(
      controller: controller,
      style: TextStyle(color: colors.text, fontSize: 14),
      onChanged: (_) {
        if (_error != null && controller == _urlController)
          setState(() => _error = null);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: colors.textMuted.withOpacity(0.7),
          fontSize: 14,
        ),
        errorText: error,
        errorStyle: TextStyle(color: colors.danger, fontSize: 11.5),
        filled: true,
        fillColor: colors.cardBg.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.danger),
        ),
      ),
    );
  }
}
