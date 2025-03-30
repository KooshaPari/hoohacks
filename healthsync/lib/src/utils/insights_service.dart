import 'dart:convert';
import 'package:http/http.dart' as http;

class HealthInsight {
  final String summary;
  final List<String> recommendations;

  HealthInsight({required this.summary, required this.recommendations});

  factory HealthInsight.fromJson(Map<String, dynamic> json) {
    return HealthInsight(
      summary: json['summary'] ?? 'No insights available',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  // Default placeholder when no data is available
  factory HealthInsight.placeholder() {
    return HealthInsight(
      summary: 'Start tracking your health to see personalized insights!',
      recommendations: [
        'Add daily entries about how you feel',
        'Track your symptoms consistently',
        'Note any patterns you notice in your health'
      ],
    );
  }
}

class InsightsService {
  static const String baseUrl = 'http://your-server-address:5002'; // Update with your server address

  Future<HealthInsight> getHealthInsights() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_health_insights'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HealthInsight.fromJson(data);
      } else {
        print('Error fetching insights: ${response.statusCode}');
        return HealthInsight.placeholder();
      }
    } catch (e) {
      print('Exception when fetching insights: $e');
      return HealthInsight.placeholder();
    }
  }
}