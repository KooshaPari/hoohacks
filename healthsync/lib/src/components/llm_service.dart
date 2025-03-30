import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class LlmService {
  static final LlmService _instance = LlmService._internal();
  factory LlmService() => _instance;

  LlmService._internal();

  // API URL - Update with your actual backend URL
  static String get apiBaseUrl {
    // For web platform in development
    if (kIsWeb) {
      return 'http://localhost:5002'; // Local development API
    }
    // For production, you might want to use a relative URL or your actual domain
    // return 'https://yourdomain.com/api';
    
    // For native platforms, use the appropriate IP/port
    // For emulators, use 10.0.2.2 to access the host machine
    return 'http://10.0.2.2:5002';
  }
  
  // Create an HTTP client with a reasonable timeout
  http.Client _createClient() {
    return http.Client();
  }
  
  /// Get raw response from the LLM
  Future<String> getResponse(String prompt) async {
    final client = _createClient();
    
    try {
      final response = await client.get(
        Uri.parse('$apiBaseUrl/get_response?prompt=${Uri.encodeComponent(prompt)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? '';
      } else {
        print('Error getting LLM response: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      print('Network error getting LLM response: $e');
      return '';
    } finally {
      client.close();
    }
  }

  /// Analyze health data entries
  Future<Map<String, dynamic>> analyzeHealthData(
    List<dynamic> entries, 
    String userId, 
    {String timeframe = 'week'}
  ) async {
    final client = _createClient();
    
    try {
      final response = await client.post(
        Uri.parse('$apiBaseUrl/analyze_health_data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'entries': entries,
          'timeframe': timeframe,
          'user_id': userId
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error analyzing health data: ${response.statusCode} - ${response.body}');
        return {'error': 'Failed to analyze health data'};
      }
    } catch (e) {
      print('Network error analyzing health data: $e');
      return {'error': 'Network error: $e'};
    } finally {
      client.close();
    }
  }

  /// Generate summary from health data entries
  Future<Map<String, dynamic>> generateSummary(
    List<dynamic> entries, 
    String userId, 
    {String timeframe = 'week'}
  ) async {
    final client = _createClient();
    
    try {
      final response = await client.post(
        Uri.parse('$apiBaseUrl/generate_summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'entries': entries,
          'timeframe': timeframe,
          'user_id': userId
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error generating summary: ${response.statusCode} - ${response.body}');
        return {'error': 'Failed to generate summary'};
      }
    } catch (e) {
      print('Network error generating summary: $e');
      return {'error': 'Network error: $e'};
    } finally {
      client.close();
    }
  }

  /// Generate reflection from multiple summaries
  Future<Map<String, dynamic>> generateReflection(
    List<String> summaries, 
    String userId, 
    {String timeframe = 'month'}
  ) async {
    final client = _createClient();
    
    try {
      final response = await client.post(
        Uri.parse('$apiBaseUrl/generate_reflection'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'summaries': summaries,
          'timeframe': timeframe,
          'user_id': userId
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error generating reflection: ${response.statusCode} - ${response.body}');
        return {'error': 'Failed to generate reflection'};
      }
    } catch (e) {
      print('Network error generating reflection: $e');
      return {'error': 'Network error: $e'};
    } finally {
      client.close();
    }
  }
  
  /// Complete health template from user input
  Future<Map<String, dynamic>> completeHealthTemplate(
    Map<String, dynamic> template,
    String userInput
  ) async {
    final client = _createClient();
    
    try {
      final response = await client.post(
        Uri.parse('$apiBaseUrl/complete_health_template'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'template': template,
          'user_input': userInput
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error completing health template: ${response.statusCode} - ${response.body}');
        return {'error': 'Failed to complete health template'};
      }
    } catch (e) {
      print('Network error completing health template: $e');
      return {'error': 'Network error: $e'};
    } finally {
      client.close();
    }
  }
  
  /// Handle offline mode by providing simulated responses
  Map<String, String> _getOfflineResponse(String type) {
    if (type == 'analysis') {
      return {
        'analysis': 'Your mood has been fluctuating with higher energy levels in the mornings. There seem to be recurring headache symptoms that may be worth tracking more closely. Overall, your health trends appear stable with some areas for potential improvement in sleep quality.'
      };
    } else if (type == 'summary') {
      return {
        'summary': 'This week shows a pattern of variable mood with generally good energy levels. Your headaches appear to be more frequent in the afternoons, possibly related to screen time. Consider taking short breaks from screens and staying hydrated to potentially improve symptoms.',
        'analysis': 'Detailed analysis shows correlation between reported headaches and extended periods of screen usage. Energy levels peak in morning hours and decline throughout the day.'
      };
    } else if (type == 'reflection') {
      return {
        'reflection': 'Looking at your health data over the past month, there's a clear pattern of symptom improvement when you maintain regular sleep schedules. Consider establishing a more consistent bedtime routine to potentially reduce the frequency of headaches and improve overall wellbeing.'
      };
    }
    return {'error': 'Unknown response type'};
  }
  
  /// Check if the API is available
  Future<bool> isApiAvailable() async {
    final client = _createClient();
    try {
      final response = await client.get(
        Uri.parse('$apiBaseUrl/'),
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      print('LLM API not available: $e');
      return false;
    } finally {
      client.close();
    }
  }
}