import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/themed_background.dart';
import '../services/profile_service.dart';
import '../widgets/user_avatar.dart';
import '../widgets/zenda_text_field.dart';
import '../widgets/zenda_toast.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController workplaceController = TextEditingController();
  final ProfileService profileService = ProfileService();
  String? _avatarUrl;
  bool _uploading = false;
  bool _saving = false;
  String? _firstNameError;
  String? _lastNameError;
  int _shakeTick = 0;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.profile['firstName'] ?? '';
    lastNameController.text = widget.profile['lastName'] ?? '';
    workplaceController.text = widget.profile['workplace'] ?? '';
    _avatarUrl = widget.profile['avatarUrl'];
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    workplaceController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_uploading) return;
    final t = AppLocalizations.of(context);
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    final bytes = await picked.readAsBytes();
    final url = await profileService.uploadAvatar(bytes, picked.name);
    if (!mounted) return;
    setState(() => _uploading = false);

    if (url != null) {
      setState(() => _avatarUrl = url);
      showZendaToast(context, t.photoUpdated, type: ZendaToastType.success);
    } else if (profileService.lastError != null) {
      showZendaToast(
        context,
        t.photoUploadError,
        subtitle: profileService.lastError,
      );
    }
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _firstNameError = firstNameController.text.trim().isEmpty
          ? t.firstNameRequired
          : null;
      _lastNameError = lastNameController.text.trim().isEmpty
          ? t.lastNameRequired
          : null;
      _shakeTick++;
    });
    if (_firstNameError != null || _lastNameError != null) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final workplace = workplaceController.text.trim();
    final ok = await profileService.update(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      workplace: workplace.isEmpty ? null : workplace,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      showZendaToast(context, t.profileUpdated, type: ZendaToastType.success);
      Navigator.pop(context, true);
    } else if (profileService.lastError != null) {
      showZendaToast(
        context,
        t.profileSaveError,
        subtitle: profileService.lastError,
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
                            t.profileEdit,
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
                      padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              children: [
                                UserAvatar(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  avatarUrl: _avatarUrl,
                                  size: 92,
                                  colors: colors,
                                ),
                                if (_uploading)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.35),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                PositionedDirectional(
                                  end: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: colors.accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.bgA,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.photo_camera_outlined,
                                      size: 15,
                                      color: colors.onAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Text(
                              t.changePhoto,
                              style: TextStyle(
                                color: colors.accent,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _label(t.fieldFirstName, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: firstNameController,
                            hint: t.hintFirstName,
                            colors: colors,
                            errorText: _firstNameError,
                            shakeTick: _shakeTick,
                            onChanged: (_) =>
                                setState(() => _firstNameError = null),
                          ),
                          const SizedBox(height: 14),
                          _label(t.fieldLastName, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: lastNameController,
                            hint: t.hintLastName,
                            colors: colors,
                            errorText: _lastNameError,
                            shakeTick: _shakeTick,
                            onChanged: (_) =>
                                setState(() => _lastNameError = null),
                          ),
                          const SizedBox(height: 14),
                          _label(t.fieldWorkplace, colors),
                          const SizedBox(height: 8),
                          ZendaTextField(
                            controller: workplaceController,
                            hint: t.workplaceHint,
                            colors: colors,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 4,
                              ),
                              child: Text(
                                t.emailLabel(widget.profile['email'] ?? ''),
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 12,
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
                              onPressed: _saving || _uploading ? null : _save,
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
