import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:healthsync/src/models/user_model.dart';

class UserService {
  // API URL - Update with your actual backend URL
  // Using the same base URL as in the EntryPage
  static const String apiBaseUrl = 'http://10.142.40.109:5001';

  // Create a new user in the database
  Future<User?> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print('Error creating user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error creating user: $e');
      return null;
    }
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    if (email.isEmpty) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users/email/$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        // User not found, which is a valid scenario
        return null;
      } else {
        print('Error getting user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error getting user by email: $e');
      return null;
    }
  }

  // Get user by Auth0 ID (sub field)
  Future<User?> getUserByAuth0Id(String auth0Id) async {
    if (auth0Id.isEmpty) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users/auth0/$auth0Id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        // User not found, which is a valid scenario
        return null;
      } else {
        print('Error getting user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error getting user by Auth0 ID: $e');
      return null;
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
