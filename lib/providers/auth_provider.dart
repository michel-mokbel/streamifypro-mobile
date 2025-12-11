import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api/api_client.dart';
import '../core/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _api.login(username, password);
      final userJson = (data['user'] ?? {}) as Map<String, dynamic>;
      _currentUser = User.fromJson(userJson);
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await _secure.write(key: 'auth_token', value: token);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = const User(id: 0, username: 'Guest', email: '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _api.signup(username, email, password);
      final userJson = (data['user'] ?? {}) as Map<String, dynamic>;
      _currentUser = User.fromJson(userJson);
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await _secure.write(key: 'auth_token', value: token);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    _currentUser = null;
    await _secure.delete(key: 'auth_token');
    notifyListeners();
  }

  Future<String?> getMemberSince() async {
    final existing = await _secure.read(key: 'member_since');
    if (existing != null && existing.isNotEmpty) return existing;
    final now = DateTime.now();
    final formatted = '${_monthName(now.month)} ${now.day}, ${now.year}';
    await _secure.write(key: 'member_since', value: formatted);
    return formatted;
  }

  String _monthName(int m) {
    const names = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return names[(m - 1).clamp(0, 11)];
  }
}

