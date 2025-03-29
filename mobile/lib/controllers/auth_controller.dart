import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, error }

class AuthController with ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _token;
  String? _userId;
  String? _errorMessage;
  
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  AuthStatus get status => _status;
  String? get token => _token;
  String? get userId => _userId;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthController() {
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await _storage.read(key: 'token');
    final userId = await _storage.read(key: 'userId');
    
    if (token != null && userId != null) {
      _token = token;
      _userId = userId;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.initial;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['userId'];
        
        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'userId', value: _userId);
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        _errorMessage = error['message'] ?? 'Login failed';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _status = AuthStatus.initial;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        return login(email, password);
      } else {
        final error = jsonDecode(response.body);
        _errorMessage = error['message'] ?? 'Registration failed';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
    _token = null;
    _userId = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
