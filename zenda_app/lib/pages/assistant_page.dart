import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/themed_moon_icon.dart';
import '../services/api_client.dart';
import '../services/assistant_service.dart';
import '../widgets/schedule_item_sheet.dart';
import '../widgets/zenda_toast.dart';
import 'note_form_page.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final AssistantService assistantService = AssistantService();
  final TextEditingController _input = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  final List<Map<String, dynamic>> _messages = [];
  bool _loadingHistory = true;
  bool _waiting = false;
  bool _busy = false;
  bool _recording = false;
  bool _transcribing = false;
  bool _openingSource = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  static const int _maxRecordSeconds = 60;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    _input.dispose();
    assistantService.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await assistantService.history();
    if (!mounted) return;
    setState(() {
      _loadingHistory = false;
      if (history != null) {
        _messages
          ..clear()
          ..addAll(
            history.map<Map<String, dynamic>>(
              (m) => {
                'role': m['role'],
                'content': m['content'] ?? '',
                'sources': m['sources'] ?? [],
              },
            ),
          );
      }
    });
  }

  String _cleanText(String text) {
    final lines = <String>[];
    for (final raw
        in text.replaceAll('**', '').replaceAll('__', '').split('\n')) {
      final line = raw.trimRight();
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('|')) {
        if (RegExp(r'^\|?[\s\-:|]+\|?$').hasMatch(trimmed)) continue;
        final cells = trimmed
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty && c != '-' && c != '–' && c != '—')
            .toList();
        if (cells.isNotEmpty) lines.add('• ${cells.join(' · ')}');
        continue;
      }
      if (trimmed.startsWith('#')) {
        lines.add(trimmed.replaceFirst(RegExp(r'^#+\s*'), ''));
        continue;
      }
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        lines.add('• ${trimmed.substring(2)}');
        continue;
      }
      lines.add(line);
    }
    return lines
        .join('\n')
        .replaceAll('\u202F', ' ')
        .replaceAll('\u00A0', ' ')
        .replaceAllMapped(RegExp(r'(\d{1,2}:\d{2}):00'), (m) => m.group(1)!)
        .trim();
  }

  String _formatSeconds(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  DateTime? _parseDay(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString())?.toLocal();
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  Future<void> _openSource(dynamic source) async {
    final id = source['id'];
    final type = (source['type'] ?? '').toString();
    if (id is! int || _openingSource) return;
    final t = AppLocalizations.of(context);

    _openingSource = true;
    final data = await assistantService.source(type, id);
    _openingSource = false;
    if (!mounted) return;

    if (data == null) {
      if (assistantService.lastError != null)
        showZendaToast(context, t.sourceNotFound);
      return;
    }

    switch (data['kind']) {
      case 'item':
        await showScheduleItemSheet(
          context,
          Map<String, dynamic>.from(data['item']),
          _parseDay(data['date']),
        );
        break;
      case 'note':
        final note = Map<String, dynamic>.from(data['note']);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteFormPage(
              taskItemId: note['taskItemId'],
              eventId: note['eventId'],
              ownerTitle: data['ownerTitle'],
              ownerIsTask: data['ownerIsTask'] == true,
              existing: note,
            ),
          ),
        );
        break;
      case 'attachment':
        final url = (data['url'] ?? '').toString();
        final uri = Uri.tryParse(
          url.startsWith('/') ? '${ApiClient.baseUrl}$url' : url,
        );
        var opened = false;
        if (uri != null) {
          try {
            opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            print('Open source error: $e');
          }
        }
        if (!opened && mounted) showZendaToast(context, t.attachmentOpenError);
        break;
    }
  }

  Future<void> _toggleRecording() async {
    if (_transcribing || _busy) return;
    if (_recording) {
      await _stopRecording();
      return;
    }
    final t = AppLocalizations.of(context);

    try {
      final allowed = await _recorder.hasPermission();
      if (!allowed) {
        if (mounted)
          showZendaToast(context, t.micDenied, subtitle: t.micDeniedHint);
        return;
      }
      final path = kIsWeb
          ? ''
          : '${(await getTemporaryDirectory()).path}/zenda_voice.m4a';
      await _recorder.start(
        RecordConfig(encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc),
        path: path,
      );
    } catch (e) {
      print('Record start error: $e');
      if (mounted) showZendaToast(context, t.recordStartError);
      return;
    }

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _recording = true;
      _recordSeconds = 0;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordSeconds++);
      if (_recordSeconds >= _maxRecordSeconds) _stopRecording();
    });
  }

  Future<void> _stopRecording() async {
    if (!_recording) return;
    final t = AppLocalizations.of(context);
    _recordTimer?.cancel();
    _recordTimer = null;
    final seconds = _recordSeconds;

    String? path;
    try {
      path = await _recorder.stop();
    } catch (e) {
      print('Record stop error: $e');
    }
    if (!mounted) return;
    setState(() => _recording = false);

    if (path == null || path.isEmpty) {
      showZendaToast(context, t.recordNotSaved);
      return;
    }
    if (seconds < 1) {
      showZendaToast(context, t.recordTooShort, subtitle: t.recordTooShortHint);
      return;
    }

    setState(() => _transcribing = true);
    final bytes = await XFile(path).readAsBytes();
    final text = await assistantService.transcribe(
      bytes,
      kIsWeb ? 'voice.webm' : 'voice.m4a',
    );
    if (!mounted) return;
    setState(() => _transcribing = false);

    if (text == null) {
      showZendaToast(
        context,
        t.transcribeError,
        subtitle: assistantService.lastError ?? t.assistantCheckService,
      );
      return;
    }
    final recognized = text.trim();
    if (recognized.isEmpty) {
      showZendaToast(
        context,
        t.transcribeEmpty,
        subtitle: t.transcribeEmptyHint,
      );
      return;
    }

    final current = _input.text.trim();
    final next = current.isEmpty ? recognized : '$current $recognized';
    _input.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  Future<void> _send([String? text]) async {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty || _busy || _recording || _transcribing) return;
    _input.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': question});
      _waiting = true;
      _busy = true;
    });

    final answer = <String, dynamic>{
      'role': 'assistant',
      'content': '',
      'sources': <dynamic>[],
      'streaming': true,
    };
    var started = false;
    var failed = false;

    final connected = await assistantService.askStream(
      question,
      onToken: (token) {
        if (!mounted) return;
        setState(() {
          if (!started) {
            started = true;
            _waiting = false;
            _messages.add(answer);
          }
          answer['content'] = '${answer['content']}$token';
        });
      },
      onDone: (sources) {
        if (!mounted) return;
        setState(() {
          if (!started) {
            started = true;
            _messages.add(answer);
          }
          answer['streaming'] = false;
          answer['sources'] = sources;
          _waiting = false;
        });
      },
      onError: (message) {
        failed = true;
        if (!mounted) return;
        setState(() {
          _waiting = false;
          if (started) _messages.remove(answer);
          _messages.add({
            'role': 'error',
            'content': message,
            'question': question,
          });
        });
      },
    );

    if (!mounted) return;
    if (!connected && !started && !failed) {
      await _sendViaHttp(question);
    } else if (!connected && started && !failed) {
      setState(() => answer['streaming'] = false);
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _waiting = false;
      });
    }
  }

  Future<void> _sendViaHttp(String question) async {
    final data = await assistantService.ask(question);
    if (!mounted) return;
    final t = AppLocalizations.of(context);
    setState(() {
      _waiting = false;
      if (data != null) {
        _messages.add({
          'role': 'assistant',
          'content': data['answer'] ?? '',
          'sources': data['sources'] ?? [],
          'animate': true,
        });
      } else {
        _messages.add({
          'role': 'error',
          'content': assistantService.lastError ?? t.assistantNoAnswer,
          'question': question,
        });
      }
    });
  }

  void _retry(Map<String, dynamic> errorMessage) {
    if (_busy) return;
    final question = errorMessage['question'] as String;
    setState(() {
      final index = _messages.indexOf(errorMessage);
      if (index > 0 && _messages[index - 1]['role'] == 'user') {
        _messages.removeAt(index);
        _messages.removeAt(index - 1);
      } else {
        _messages.remove(errorMessage);
      }
    });
    _send(question);
  }

  Future<void> _clear(ThemeColors colors) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.bgA,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          t.clearHistoryTitle,
          style: TextStyle(
            color: colors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          t.clearHistoryText,
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
              t.clearButton,
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
    final ok = await assistantService.clear();
    if (!mounted) return;
    if (ok) {
      setState(() => _messages.clear());
      showZendaToast(context, t.historyCleared, type: ZendaToastType.success);
    } else if (assistantService.lastError != null) {
      showZendaToast(
        context,
        t.clearHistoryError,
        subtitle: assistantService.lastError,
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
        final bottomPadding = MediaQuery.of(context).padding.bottom + 12;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: _header(colors, t),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: _body(colors, t),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
                child: _inputBar(colors, t),
              ),
            ],
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
                t.navAssistant,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t.assistantSubtitle,
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        if (_messages.isNotEmpty)
          GestureDetector(
            onTap: _busy ? null : () => _clear(colors),
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
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 13,
                    color: colors.accent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    t.clearButton,
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

  Widget _body(ThemeColors colors, AppLocalizations t) {
    if (_loadingHistory) {
      return Center(
        child: CircularProgressIndicator(color: colors.accent, strokeWidth: 2),
      );
    }
    if (_messages.isEmpty && !_waiting) {
      return _welcome(colors, t);
    }
    final count = _messages.length + (_waiting ? 1 : 0);
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      itemCount: count,
      itemBuilder: (context, index) {
        if (_waiting && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _typingBubble(colors),
            ),
          );
        }
        final messageIndex =
            _messages.length - 1 - (index - (_waiting ? 1 : 0));
        final message = _messages[messageIndex];
        return Padding(
          padding: EdgeInsets.only(top: messageIndex == 0 ? 0 : 18),
          child: _messageBubble(message, colors, t),
        );
      },
    );
  }

  Widget _welcome(ThemeColors colors, AppLocalizations t) {
    final suggestions = [
      t.suggestionToday,
      t.suggestionUrgent,
      t.suggestionWeek,
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const ThemedMoonIcon(size: 61),
          const SizedBox(height: 18),
          Text(
            t.welcomeTitle,
            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.welcomeText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (s) => GestureDetector(
                    onTap: () => _send(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: colors.glassBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.glassBorder),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(
    Map<String, dynamic> message,
    ThemeColors colors,
    AppLocalizations t,
  ) {
    final maxWidth = MediaQuery.of(context).size.width * 0.74;
    final role = message['role'];

    if (role == 'user') {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            message['content'] ?? '',
            style: TextStyle(
              color: colors.onAccent,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    if (role == 'error') {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
          decoration: BoxDecoration(
            color: colors.glassBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.danger.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message['content'] ?? '',
                style: TextStyle(
                  color: colors.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.assistantCheckService,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _busy ? null : () => _retry(message),
                child: Text(
                  t.commonRetry,
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<dynamic> sources = message['sources'] ?? [];
    final animate = message['animate'] == true;
    final streaming = message['streaming'] == true;
    final content = _cleanText(message['content'] ?? '');
    final textStyle = TextStyle(color: colors.text, fontSize: 13, height: 1.45);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            animate
                ? _TypewriterText(
                    text: content,
                    style: textStyle,
                    onDone: () {
                      if (mounted) setState(() => message['animate'] = false);
                    },
                  )
                : Text(content, style: textStyle),
            if (!animate && !streaming && sources.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sources
                    .map<Widget>((s) => _sourceChip(s, colors))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sourceChip(dynamic source, ThemeColors colors) {
    final IconData icon;
    switch (source['type']) {
      case 'task':
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'event':
        icon = Icons.event_outlined;
        break;
      case 'attachment':
        icon = Icons.attach_file_rounded;
        break;
      default:
        icon = Icons.sticky_note_2_outlined;
    }
    return GestureDetector(
      onTap: () => _openSource(source),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.accent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: colors.accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                source['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typingBubble(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.glassBorder),
      ),
      child: _TypingDots(color: colors.accent),
    );
  }

  Widget _inputBar(ThemeColors colors, AppLocalizations t) {
    final locked = _busy || _transcribing;
    return Container(
      height: 50,
      padding: const EdgeInsetsDirectional.only(start: 18, end: 6),
      decoration: BoxDecoration(
        color: colors.navBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _recording ? colors.danger.withOpacity(0.5) : colors.navBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _inputContent(colors, t)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: locked ? null : _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _recording ? colors.danger : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: _transcribing
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        color: colors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _recording ? Icons.stop_rounded : Icons.mic_none_rounded,
                      color: _recording
                          ? Colors.white
                          : (locked ? colors.textMuted : colors.accent),
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: locked || _recording ? null : () => _send(),
            child: AnimatedOpacity(
              opacity: locked || _recording ? 0.5 : 1,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.onAccent,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputContent(ThemeColors colors, AppLocalizations t) {
    if (_recording) {
      return Row(
        children: [
          _PulsingDot(color: colors.danger),
          const SizedBox(width: 8),
          Text(
            t.recordingLabel(_formatSeconds(_recordSeconds)),
            style: TextStyle(
              color: colors.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.recordingHint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textMuted, fontSize: 11.5),
            ),
          ),
        ],
      );
    }
    if (_transcribing) {
      return Text(
        t.transcribing,
        style: TextStyle(color: colors.textMuted, fontSize: 13.5),
      );
    }
    return TextField(
      controller: _input,
      style: TextStyle(color: colors.text, fontSize: 13.5),
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _send(),
      decoration: InputDecoration.collapsed(
        hintText: t.inputHint,
        hintStyle: TextStyle(
          color: colors.textMuted.withOpacity(0.8),
          fontSize: 13.5,
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1).animate(_controller),
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final VoidCallback onDone;

  const _TypewriterText({
    required this.text,
    required this.style,
    required this.onDone,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late final List<String> _words = widget.text.split(' ');
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_words.length * 35).clamp(400, 4000)),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final count = (_controller.value * _words.length).ceil().clamp(
          0,
          _words.length,
        );
        return Text(_words.take(count).join(' '), style: widget.style);
      },
    );
  }
}

class _TypingDots extends StatefulWidget {
  final Color color;

  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = sin(_controller.value * 2 * pi - i * 0.8);
            final opacity = 0.3 + 0.7 * (phase + 1) / 2;
            return Container(
              margin: EdgeInsetsDirectional.only(end: i == 2 ? 0 : 5),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
