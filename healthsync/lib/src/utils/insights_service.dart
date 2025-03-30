import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

// Import weekly_summary to access the global healthData (temporary solution)
import 'package:healthsync/src/pages/weekly_summary.dart' as weekly_summary;

class HealthInsight {
  final String summary; // This might become less relevant if Gemini provides recommendations directly
  final List<String> recommendations;

  HealthInsight({required this.summary, required this.recommendations});

  // Keep the fromJson factory if your Gemini response structure matches this
  factory HealthInsight.fromJson(Map<String, dynamic> json) {
    // Adapt this based on the actual Gemini response structure if needed
    return HealthInsight(
      summary: json['summary'] ?? 'Insights generated.', // Or derive from recommendations
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  // Placeholder remains useful for loading/error states
  factory HealthInsight.placeholder() {
    return HealthInsight(
      summary: 'Generating your personalized health insights...',
      recommendations: [
        'Make sure you have recent journal entries.',
        'Ensure your health data is tracked.',
        'Insights will appear here shortly.',
      ],
    );
  }

  // Factory for error state
   factory HealthInsight.error(String errorMessage) {
    return HealthInsight(
      summary: 'Could not generate insights',
      recommendations: [
        'Error: $errorMessage',
        'Please check your connection and try again.',
        'Ensure the backend server is running.',
      ],
    );
  }
}

class InsightsService {
  // --- Configuration ---
  // IMPORTANT: Replace YOUR_LOCAL_IP with your actual local network IP
  static const String _backendBaseUrl = 'http://10.142.40.109:5001'; // Example IP, ensure it's correct
  static final String? _geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  // --- End Configuration ---

  // Helper to fetch journal entries from the Python backend
  Future<List<Map<String, dynamic>>> _fetchJournalEntries(DateTime startDate, DateTime endDate) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final String startDateStr = formatter.format(startDate);
    final String endDateStr = formatter.format(endDate);

    final uri = Uri.parse('$_backendBaseUrl/get_entries?start_date=$startDateStr&end_date=$endDateStr');

    print('Fetching journal entries from: $uri'); // Debug log

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15)); // Increased timeout

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
         print('Received ${data.length} journal entries.'); // Debug log
        // Ensure data is List<Map<String, dynamic>>
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('Error fetching journal entries: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load journal entries (${response.statusCode})');
      }
    } catch (e) {
      print('Exception when fetching journal entries: $e');
      throw Exception('Network error fetching journal entries: $e');
    }
  }

  // Helper to generate insights using Gemini - NOW ACCEPTS STRINGS
  Future<List<String>> _generateInsightsFromData(
      String journalEntriesString, // Changed parameter
      String healthKitDataString   // Changed parameter
      ) async {

    if (_geminiApiKey == null) {
      print('Error: GEMINI_API_KEY not found in .env file.');
      throw Exception('Gemini API Key is not configured.');
    }

    // Initialize Gemini AI Model
    // Note: Using 'gemini-1.5-flash-latest' as 'gemini-pro' caused errors.
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: _geminiApiKey!);

    // --- Construct the Prompt ---
    // Use the pre-formatted strings directly
    String prompt = """
Analyze the following health data and journal entries for the past week. Provide exactly 3 concise, actionable, one-line recommendations based on potential patterns, correlations, or areas for improvement. Focus on practical advice.

Recent Journal Entries:
${journalEntriesString.isEmpty ? "No journal entries found for the selected period." : journalEntriesString}

Weekly Health Data Summary:
${healthKitDataString.isEmpty ? "No health data found for the selected period." : healthKitDataString}

Recommendations:
1.
2.
3.
""";
    // --- End Prompt Construction ---

    print("--- Sending Prompt to Gemini ---");
    print(prompt); // Debug log
    print("-----------------------------");


    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      print("--- Received Response from Gemini ---");
      print(response.text); // Debug log
      print("-----------------------------------");


      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      // Extract the recommendations (assuming they are numbered lines)
      final lines = response.text!
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line.length > 2 && line.substring(1, 3).contains('.')) // Basic check for "1.", "2.", etc.
          .map((line) => line.substring(line.indexOf('.') + 1).trim()) // Get text after "X."
          .toList();

      if (lines.length < 3) {
         print("Warning: Gemini response did not contain 3 numbered recommendations. Returning raw response lines.");
         // Fallback: return any non-empty lines if parsing fails
         return response.text!.split('\n').map((l)=>l.trim()).where((l) => l.isNotEmpty).toList();
      }

      return lines.take(3).toList(); // Return the first 3 parsed recommendations

    } catch (e) {
      print('Exception when calling Gemini API: $e');
      // Check for specific API errors if the SDK provides them
      if (e.toString().contains('API key not valid')) {
         throw Exception('Invalid Gemini API Key. Please check your .env file.');
      }
      throw Exception('Failed to generate insights using AI: $e');
    }
  }

  // Main method called by the UI
  Future<HealthInsight> getHealthInsights() async {
    try {
      // 1. Define date range (e.g., last 7 days)
      final DateTime endDate = DateTime.now();
      final DateTime startDate = endDate.subtract(const Duration(days: 7));

      // 2. Fetch journal entries from backend
      final journalEntries = await _fetchJournalEntries(startDate, endDate);

      // 3. Get HealthKit data (using the global variable from weekly_summary.dart)
      final healthKitData = weekly_summary.healthData;

      // --- Format Data into Strings ---
      String journalEntriesString = "";
      try {
        // Use jsonEncode for a robust string representation of the list of maps
        journalEntriesString = jsonEncode(journalEntries);
      } catch (e) {
        print("Could not JSON encode journal entries for prompt: $e");
        journalEntriesString = "Error encoding journal entries."; // Provide fallback
      }

      String healthKitDataString = "";
      try {
          StringBuffer healthBuffer = StringBuffer();
          healthKitData.forEach((key, values) {
            String keyName = key.toString().split('.').last;
            // Basic check for non-empty list before reducing
            if (values.isNotEmpty) {
               String avgValue = (values.reduce((a, b) => a + b) / values.length).toStringAsFixed(1);
               healthBuffer.writeln("- Average ${keyName.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').toLowerCase()}: $avgValue");
            } else {
               healthBuffer.writeln("- Average ${keyName.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').toLowerCase()}: N/A (no data)");
            }
          });
          healthKitDataString = healthBuffer.toString();
      } catch (e) {
          print("Could not format HealthKit data for prompt: $e");
          healthKitDataString = "Error formatting HealthKit data."; // Provide fallback
      }

      // --- Logging the formatted strings ---
      print("--- Data Strings for Gemini ---");
      print("Journal Entries String:\n$journalEntriesString");
      print("\nHealthKit Data String:\n$healthKitDataString");
      print("-----------------------------");
      // --- End Logging ---


      // 4. Generate insights using Gemini - PASSING STRINGS
      final recommendations = await _generateInsightsFromData(
          journalEntriesString,
          healthKitDataString
      );

      // 5. Return the result
      return HealthInsight(summary: "Here are your weekly insights:", recommendations: recommendations);

    } catch (e) {
      print('Error in getHealthInsights: $e');
      // Return a specific error insight
      return HealthInsight.error(e.toString());
    }
  }
}