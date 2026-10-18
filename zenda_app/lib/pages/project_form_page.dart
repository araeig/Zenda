import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../l10n/date_format.dart';
import '../theme/app_theme.dart';
import '../theme/themed_background.dart';
import '../theme/picker_theme.dart';
import '../widgets/zenda_text_field.dart';
import '../widgets/zenda_toast.dart';
import '../services/project_service.dart';

class ProjectFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const ProjectFormPage({super.key, this.existing});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final TextEditingController nameController = TextEditingController();
  final ProjectService projectService = ProjectService();
  DateTime? _deadline;
  bool _isLoading = false;
  String? _nameError;
  int _shakeTick = 0;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      nameController.text = existing['name'] ?? '';
      final parsed = existing['deadline'] == null
          ? null
          : DateTime.tryParse(existing['deadline'].toString())?.toLocal();
      if (parsed != null)
        _deadline = DateTime(parsed.year, parsed.month, parsed.day);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: zendaPickerTheme,
    );
    if (picked != null)
      setState(
        () => _deadline = DateTime(picked.year, picked.month, picked.day),
      );
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _nameError = nameController.text.trim().isEmpty
          ? t.fieldNameRequired
          : null;
      _shakeTick++;
    });
    if (_nameError != null) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final name = nameController.text.trim();
    final success = _isEdit
        ? await projectService.update(
            widget.existing!['id'],
            name: name,
            deadline: _deadline,
          )
        : await projectService.create(name: name, deadline: _deadline);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      showZendaToast(
        context,
        _isEdit ? t.projectUpdated : t.projectCreated,
        type: ZendaToastType.success,
      );
      Navigator.pop(context, true);
    } else if (projectService.lastError != null) {
      showZendaToast(
        context,
        _isEdit ? t.projectSaveError : t.projectCreateError,
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
                                ? t.projectFormEditTitle
                                : t.projectFormNewTitle,
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
                            controller: nameController,
                            hint: t.projectNameHint,
                            colors: colors,
                            errorText: _nameError,
                            shakeTick: _shakeTick,
                            onChanged: (_) {
                              if (_nameError != null)
                                setState(() => _nameError = null);
                            },
                          ),
                          const SizedBox(height: 14),
                          _label(t.fieldDeadline, colors),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDeadline,
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              padding: const EdgeInsetsDirectional.only(
                                start: 16,
                                end: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colors.cardBg.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _deadline == null
                                          ? t.deadlineNone
                                          : formatWeekdayDayMonth(_deadline!),
                                      style: TextStyle(
                                        color: _deadline == null
                                            ? colors.textMuted.withOpacity(0.7)
                                            : colors.text,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (_deadline != null)
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _deadline = null),
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 4,
                              ),
                              child: Text(
                                t.projectDeadlineHelp,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
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
                                      _isEdit ? t.commonSave : t.projectCreate,
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
}
