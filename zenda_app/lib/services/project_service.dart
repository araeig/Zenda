import 'api_client.dart';
import 'data_events.dart';

class ProjectService {
  final ApiClient _api = ApiClient();
  String? lastError;

  String _dateParam(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool _handle(dynamic response) {
    if (response == null) return false;
    if (response['status'] != true) {
      lastError = response['message'] ?? 'Сервер не принял данные';
      return false;
    }
    notifyDataChanged();
    return true;
  }

  Future<Map<String, dynamic>?> getHome() async {
    final response = await _api.get('/projects/home');
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<List<dynamic>?> getArchive() async {
    final response = await _api.get('/projects/archive');
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<bool> create({required String name, DateTime? deadline}) async {
    lastError = null;
    final response = await _api.post('/projects', {
      'name': name,
      'deadline': deadline == null ? null : _dateParam(deadline),
    });
    return _handle(response);
  }

  Future<bool> update(
    int id, {
    required String name,
    DateTime? deadline,
  }) async {
    lastError = null;
    final response = await _api.put('/projects/$id', {
      'name': name,
      'deadline': deadline == null ? null : _dateParam(deadline),
    });
    return _handle(response);
  }

  Future<bool> restore(int id) async {
    lastError = null;
    return _handle(await _api.post('/projects/$id/restore', {}));
  }
}
