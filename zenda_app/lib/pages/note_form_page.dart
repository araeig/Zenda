import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/themed_background.dart';
import '../services/note_service.dart';
import '../widgets/zenda_text_field.dart';
import '../widgets/zenda_toast.dart';

class NoteFormPage extends StatefulWidget {
  final int? taskItemId;
  final int? eventId;
  final String? ownerTitle;
  final bool ownerIsTask;
  final Map<String, dynamic>? existing;

  const NoteFormPage({
    super.key,
    this.taskItemId,
    this.eventId,
    this.ownerTitle,
    this.ownerIsTask = true,
    this.existing,
  });

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final NoteService noteService = NoteService();
  bool _saving = false;
  String? _contentError;
  int _shakeTick = 0;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      final title = (existing['title'] ?? '').toString();
      final content = (existing['content'] ?? '').toString();
      titleController.text = _isAutoTitle(title, content) ? '' : title;
      contentController.text = content;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  bool _isAutoTitle(String title, String content) {
    final base = title.endsWith('…')
        ? title.substring(0, title.length - 1).trimRight()
        : title.trim();
    return base.isNotEmpty && content.trim().startsWith(base);
  }

  String _autoTitle(String content) {
    final firstLine = content.split('\n').first.trim();
    if (firstLine.length <= 40) return firstLine;
    return '${firstLine.substring(0, 40).trimRight()}…';
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final content = contentController.text.trim();
    setState(() {
      _contentError = content.isEmpty ? t.noteTextRequired : null;
      _shakeTick++;
    });
    if (_contentError != null) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final typedTitle = titleController.text.trim();
    final title = typedTitle.isEmpty ? _autoTitle(content) : typedTitle;
    final existing = widget.existing;
    final ok = existing != null
        ? await noteService.update(
            existing['id'],
            title: title,
            content: content,
            taskItemId: existing['taskItemId'],
            eventId: existing['eventId'],
          )
        : await noteService.create(
            title: title,
            content: content,
            taskItemId: widget.taskItemId,
            eventId: widget.eventId,
          );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      showZendaToast(context, t.noteSaved, type: ZendaToastType.success);
      Navigator.pop(context, true);
    } else if (noteService.lastError != null) {
      showZendaToast(context, t.noteSaveError, subtitle: noteService.lastError);
    }
  }

  Future<void> _delete(ThemeColors colors) async {
    final t = AppLocalizations.of(context);
    final existing = widget.existing;
    if (existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.bgA,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          t.noteDeleteTitle,
          style: TextStyle(
            color: colors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          t.deleteIrreversible,
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

    setState(() => _saving = true);
    final ok = await noteService.delete(existing['id']);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showZendaToast(context, t.noteDeleted, type: ZendaToastType.success);
      Navigator.pop(context, true);
    } else if (noteService.lastError != null) {
      showZendaToast(
        context,
        t.noteDeleteError,
        subtitle: noteService.lastError,
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
        final owner = widget.ownerTitle;
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
                            _isEdit ? t.noteTitle : t.noteNewTitle,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_isEdit)
                          IconButton(
                            onPressed: _saving ? null : () => _delete(colors),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: colors.danger,
                              size: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (owner != null && owner.isNotEmpty) ...[
                            Text(
                              widget.ownerIsTask
                                  ? t.noteForTask(owner)
                                  : t.noteForEvent(owner),
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 12.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _label(t.fieldTitle, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: titleController,
                            hint: t.optionalHint,
                            colors: colors,
                          ),
                          const SizedBox(height: 14),
                          _label(t.fieldText, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: contentController,
                            hint: t.noteHint,
                            colors: colors,
                            maxLines: 8,
                            errorText: _contentError,
                            shakeTick: _shakeTick,
                            onChanged: (_) {
                              if (_contentError != null)
                                setState(() => _contentError = null);
                            },
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 4),
                            child: Text(
                              t.noteAssistantHint,
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                            ),
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
                              onPressed: _saving ? null : _save,
                              child: _saving
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
    return Text(
      text,
      style: TextStyle(
        color: colors.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
