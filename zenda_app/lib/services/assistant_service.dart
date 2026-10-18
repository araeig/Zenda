import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../l10n/app_localizations.dart';
import 'api_client.dart';
import 'locale_service.dart';

class AssistantService {
  final ApiClient _api = ApiClient();
  HubConnection? _hub;
  String? lastError;

  AppLocalizations get _t => lookupAppLocalizations(currentLocale.value);

  Future<HubConnection> _connection() async {
    final existing = _hub;
    if (existing != null && existing.state == HubConnectionState.Connected)
      return existing;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final hub = HubConnectionBuilder()
        .withUrl(
          '${ApiClient.baseUrl}/hubs/chat',
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .build();
    await hub.start();
    _hub = hub;
    return hub;
  }

  Future<bool> askStream(
    String question, {
    required void Function(String token) onToken,
    required void Function(List<dynamic> sources) onDone,
    required void Function(String message) onError,
  }) async {
    try {
      final hub = await _connection();
      hub.off('token');
      hub.off('done');
      hub.off('error');
      hub.on('token', (args) {
        if (args != null && args.isNotEmpty && args[0] != null)
          onToken(args[0].toString());
      });
      hub.on('done', (args) {
        final sources = args != null && args.isNotEmpty && args[0] is List
            ? args[0] as List
            : <dynamic>[];
        onDone(sources);
      });
      hub.on('error', (args) {
        onError(
          args != null && args.isNotEmpty && args[0] != null
              ? args[0].toString()
              : _t.assistantUnavailable,
        );
      });
      await hub.invoke('Ask', args: <Object>[question]);
      return true;
    } catch (e) {
      print('ChatHub error: $e');
      _hub = null;
      return false;
    }
  }

  Future<Map<String, dynamic>?> ask(String question) async {
    lastError = null;
    final response = await _api.post('/ai/chat', {
      'question': question,
    }, timeout: const Duration(seconds: 90));
    if (response == null) return null;
    if (response['status'] != true) {
      lastError = response['message'] ?? _t.assistantCouldNotAnswer;
      return null;
    }
    return response['data'];
  }

  Future<String?> transcribe(List<int> bytes, String filename) async {
    lastError = null;
    final response = await _api.upload(
      '/ai/transcribe',
      'file',
      bytes,
      filename,
    );
    if (response == null) return null;
    if (response['status'] != true) {
      lastError = response['message'] ?? _t.transcribeError;
      return null;
    }
    return (response['data']?['text'] ?? '').toString();
  }

  Future<List<dynamic>?> history() async {
    final response = await _api.get('/ai/history');
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<Map<String, dynamic>?> source(String type, int id) async {
    lastError = null;
    final response = await _api.get('/ai/source/$type/$id');
    if (response == null) return null;
    if (response['status'] != true) {
      lastError = response['message'] ?? _t.sourceNotFound;
      return null;
    }
    return response['data'];
  }

  Future<bool> clear() async {
    lastError = null;
    final response = await _api.delete('/ai/history');
    if (response == null) return false;
    if (response['status'] != true) {
      lastError = response['message'] ?? _t.clearHistoryError;
      return false;
    }
    return true;
  }

  Future<void> dispose() async {
    try {
      await _hub?.stop();
    } catch (_) {}
    _hub = null;
  }
}
