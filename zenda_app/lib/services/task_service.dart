import 'api_client.dart';
import 'data_events.dart';

class TaskService {
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

  Future<List<dynamic>?> getAll() async {
    final response = await _api.get('/tasks');
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<List<dynamic>?> getOverdue(DateTime before) async {
    final response = await _api.get(
      '/tasks/overdue?before=${_dateParam(before)}',
    );
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<bool> create({
    required int projectId,
    required String title,
    String? comment,
    String? address,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    lastError = null;
    final response = await _api.post('/tasks', {
      'projectId': projectId,
      'title': title,
      'comment': comment,
      'address': address,
      'dueDate': dueDate == null ? null : _dateParam(dueDate),
      'dueTime': dueTime,
    });
    return _handle(response);
  }

  Future<bool> update(
    int id, {
    required String title,
    String? comment,
    String? address,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    lastError = null;
    final response = await _api.put('/tasks/$id', {
      'title': title,
      'comment': comment,
      'address': address,
      'dueDate': dueDate == null ? null : _dateParam(dueDate),
      'dueTime': dueTime,
    });
    return _handle(response);
  }

  Future<bool> complete(int id) async {
    lastError = null;
    return _handle(await _api.post('/tasks/$id/complete', {}));
  }

  Future<bool> delete(int id) async {
    lastError = null;
    return _handle(await _api.delete('/tasks/$id'));
  }
}
