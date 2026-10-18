import 'api_client.dart';
import 'data_events.dart';

class AttachmentService {
  final ApiClient _api = ApiClient();
  String? lastError;

  Map<String, dynamic>? _handle(dynamic response, String fallback) {
    if (response == null) return null;
    if (response['status'] != true) {
      lastError = response['message'] ?? fallback;
      return null;
    }
    notifyDataChanged();
    return Map<String, dynamic>.from(response['data'] ?? {});
  }

  Future<Map<String, dynamic>?> uploadFile(
    List<int> bytes,
    String filename, {
    int? taskItemId,
    int? eventId,
  }) async {
    lastError = null;
    final fields = <String, String>{
      if (taskItemId != null) 'taskItemId': '$taskItemId',
      if (eventId != null) 'eventId': '$eventId',
    };
    final response = await _api.upload(
      '/attachments/upload',
      'file',
      bytes,
      filename,
      fields: fields,
    );
    return _handle(response, 'Не удалось загрузить файл');
  }

  Future<Map<String, dynamic>?> addLink(
    String url, {
    String? label,
    int? taskItemId,
    int? eventId,
  }) async {
    lastError = null;
    final response = await _api.post('/attachments/link', {
      'url': url,
      'label': label,
      'taskItemId': taskItemId,
      'eventId': eventId,
    });
    return _handle(response, 'Не удалось добавить ссылку');
  }

  Future<bool> delete(int id) async {
    lastError = null;
    final response = await _api.delete('/attachments/$id');
    if (response == null) return false;
    if (response['status'] != true) {
      lastError = response['message'] ?? 'Не удалось удалить вложение';
      return false;
    }
    notifyDataChanged();
    return true;
  }
}
