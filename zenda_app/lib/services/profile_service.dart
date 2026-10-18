import 'api_client.dart';
import 'data_events.dart';

class ProfileService {
  final ApiClient _api = ApiClient();
  String? lastError;

  bool _handle(dynamic response) {
    if (response == null) return false;
    if (response['status'] != true) {
      lastError = response['message'] ?? 'Сервер не принял данные';
      return false;
    }
    notifyDataChanged();
    return true;
  }

  Future<Map<String, dynamic>?> get() async {
    final response = await _api.get('/profile');
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<bool> update({
    required String firstName,
    required String lastName,
    String? workplace,
  }) async {
    lastError = null;
    final response = await _api.put('/profile', {
      'firstName': firstName,
      'lastName': lastName,
      'workplace': workplace,
    });
    return _handle(response);
  }

  Future<bool> updateLanguage(int languageId) async {
    lastError = null;
    final response = await _api.put('/profile/language', {
      'languageId': languageId,
    });
    return _handle(response);
  }

  Future<String?> uploadAvatar(List<int> bytes, String filename) async {
    lastError = null;
    final name = filename.contains('.') ? filename : '$filename.jpg';
    final response = await _api.upload('/profile/avatar', 'file', bytes, name);
    if (!_handle(response)) return null;
    return response['data']?['avatarUrl'];
  }
}
