import 'dart:convert';
import 'dart:async'; // For TimeoutException
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:healthsync/src/models/user_model.dart';

// Let's remove the conditional import that's causing issues

class UserService {
  // API URL - Update with your actual backend URL
  // Using a dynamic API base URL that can be configured based on environment
  static String get apiBaseUrl {
    // For web platform, use relative URL to avoid CORS
    if (kIsWeb) {
      // Since we're running on localhost:3000, use local API
      return 'http://localhost:5001'; // Local development API
      
      // For production, use relative URL
      // return '/api';
    }
    // For native platforms, use the hardcoded IP/port
    return 'http://10.142.40.109:5001';
  }
  
  // Create an HTTP client with a reasonable timeout
  static http.Client _createClient() {
    return http.Client();
  }
  
  // Helper method to handle API timeouts
  Future<http.Response> _timeoutSafeRequest(Future<http.Response> request) async {
    try {
      // Set a 5-second timeout for all API requests
      return await request.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      print('API request timed out');
      throw Exception('API request timed out');
    }
  }

  // Create a new user in the database
  Future<User?> createUser(User user) async {
    final client = _createClient();
    try {
      print('Creating user in database: ${user.email}');
      
      final response = await _timeoutSafeRequest(
        client.post(
          Uri.parse('$apiBaseUrl/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(user.toJson()),
        )
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('User created successfully in database');
        return User.fromJson(data);
      } else {
        print('Error creating user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error creating user: $e');
      return null;
    } finally {
      client.close();
    }
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    if (email.isEmpty) return null;
    
    final client = _createClient();
    try {
      print('Looking up user by email: $email');
      
      final response = await _timeoutSafeRequest(
        client.get(
          Uri.parse('$apiBaseUrl/users/email/$email'),
          headers: {'Content-Type': 'application/json'},
        )
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('User found in database');
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        // User not found, which is a valid scenario
        print('User not found in database - will need to create');
        return null;
      } else {
        print('Error getting user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error getting user by email: $e');
      return null;
    } finally {
      client.close(); 
    }
  }

  // Get user by Auth0 ID (sub field)
  Future<User?> getUserByAuth0Id(String auth0Id) async {
    if (auth0Id.isEmpty) return null;
    
    final client = _createClient();
    try {
      print('Looking up user by Auth0 ID: $auth0Id');
      
      final response = await _timeoutSafeRequest(
        client.get(
          Uri.parse('$apiBaseUrl/users/auth0/$auth0Id'),
          headers: {'Content-Type': 'application/json'},
        )
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('User found by Auth0 ID in database');
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        // User not found, which is a valid scenario
        print('User not found by Auth0 ID in database');
        return null;
      } else {
        print('Error getting user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error getting user by Auth0 ID: $e');
      return null;
    } finally {
      client.close();
    }
  }

  // Update existing user
  Future<User?> updateUser(String userId, User updatedUser) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedUser.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print('Error updating user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error updating user: $e');
      return null;
    }
  }

  // Update user's health consent
  Future<User?> updateHealthConsent(String userId, {bool? hasHealthkitConsent, bool? hasGoogleFitConsent}) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/users/$userId/health-consent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (hasHealthkitConsent != null) 'hasHealthkitConsent': hasHealthkitConsent,
          if (hasGoogleFitConsent != null) 'hasGoogleFitConsent': hasGoogleFitConsent,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print('Error updating health consent: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error updating health consent: $e');
      return null;
    }
  }
}
