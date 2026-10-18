import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'locale_service.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  String? lastError;

  Future<Map<String, dynamic>?> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    lastError = null;
    final response = await _api.post('/auth/signup', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'languageId': languageIds[currentLocale.value.languageCode],
    }, withAuth: false);

    if (response == null) return null;
    if (response['status'] != true) {
      lastError = response['message'] ?? 'Сервер не принял данные';
      return null;
    }

    await _saveSession(response['data']);
    return response['data'];
  }

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    lastError = null;
    final response = await _api.post('/auth/signin', {
      'email': email,
      'password': password,
    }, withAuth: false);

    if (response == null) return null;
    if (response['status'] != true) {
      lastError = response['message'] ?? 'Сервер не принял данные';
      return null;
    }

    await _saveSession(response['data']);
    return response['data'];
  }

  Future<Map<String, dynamic>?> getMe() async {
    final response = await _api.get('/auth/me');
    if (response == null || response['status'] != true) return null;
    return response['data'];
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('token', data['token']);
    await prefs.setInt('userId', data['userId']);
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.setBool('isLoggedIn', false);
  }

  Future<bool> forgotPassword(String email) async {
    final response = await _api.post('/auth/forgot-password', {
      'email': email,
    }, withAuth: false);
    return response != null && response['status'] == true;
  }
}
