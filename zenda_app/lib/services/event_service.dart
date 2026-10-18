import 'api_client.dart';
import 'data_events.dart';

class EventService {
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

  Future<List<dynamic>?> getByDate(DateTime date) async {
    final response = await _api.get('/events?date=${_dateParam(date)}');
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<List<dynamic>?> getRange(DateTime from, DateTime to) async {
    final response = await _api.get(
      '/events/range?from=${_dateParam(from)}&to=${_dateParam(to)}',
    );
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<bool> create({
    required String title,
    required DateTime date,
    String? startTime,
    String? endTime,
    String? address,
    String? comment,
  }) async {
    lastError = null;
    final response = await _api.post('/events', {
      'title': title,
      'date': _dateParam(date),
      'startTime': startTime,
      'endTime': endTime,
      'address': address,
      'comment': comment,
    });
    return _handle(response);
  }

  Future<bool> update(
    int id, {
    required String title,
    required DateTime date,
    String? startTime,
    String? endTime,
    String? address,
    String? comment,
  }) async {
    lastError = null;
    final response = await _api.put('/events/$id', {
      'title': title,
      'date': _dateParam(date),
      'startTime': startTime,
      'endTime': endTime,
      'address': address,
      'comment': comment,
    });
    return _handle(response);
  }

  Future<bool> delete(int id) async {
    lastError = null;
    return _handle(await _api.delete('/events/$id'));
  }
}
