import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Get auth token
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  // Set auth token
  Future<void> setToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  // Clear auth token
  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  // HTTP GET Request
  Future<dynamic> get(String endpoint) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _processResponse(response);
  }

  // HTTP POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    return _processResponse(response);
  }

  // HTTP PATCH Request
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    return _processResponse(response);
  }

  // HTTP DELETE Request
  Future<dynamic> delete(String endpoint) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _processResponse(response);
  }

  // Process HTTP Response
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return {'status': 'success'};
    } else {
      throw Exception(_handleError(response));
    }
  }

  // Handle Error Response
  String _handleError(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        final decoded = json.decode(response.body);
        if (decoded['message'] != null) {
          return decoded['message'];
        }
      } catch (_) {}
    }
    
    switch (response.statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Something went wrong';
    }
  }
}
