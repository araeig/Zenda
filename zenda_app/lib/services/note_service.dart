import 'api_client.dart';

class NoteService {
  final ApiClient _api = ApiClient();
  String? lastError;

  bool _handle(dynamic response) {
    if (response == null) return false;
    if (response['status'] != true) {
      lastError = response['message'] ?? 'Сервер не принял данные';
      return false;
    }
    return true;
  }

  Future<List<dynamic>?> getFor({int? taskItemId, int? eventId}) async {
    final query = taskItemId != null
        ? '?taskItemId=$taskItemId'
        : eventId != null
        ? '?eventId=$eventId'
        : '';
    final response = await _api.get('/notes$query');
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<bool> create({
    required String title,
    required String content,
    int? taskItemId,
    int? eventId,
  }) async {
    lastError = null;
    final response = await _api.post('/notes', {
      'title': title,
      'content': content,
      'taskItemId': taskItemId,
      'eventId': eventId,
    });
    return _handle(response);
  }

  Future<bool> update(
    int id, {
    required String title,
    required String content,
    int? taskItemId,
    int? eventId,
  }) async {
    lastError = null;
    final response = await _api.put('/notes/$id', {
      'title': title,
      'content': content,
      'taskItemId': taskItemId,
      'eventId': eventId,
    });
    return _handle(response);
  }

  Future<bool> delete(int id) async {
    lastError = null;
    return _handle(await _api.delete('/notes/$id'));
  }
}
