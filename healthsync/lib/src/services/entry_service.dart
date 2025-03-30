import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:health/health.dart';
import 'package:healthsync/src/models/entry_model.dart';
import 'package:healthsync/src/services/auth_service.dart';
import 'package:healthsync/src/services/health_service.dart';

class EntryService {
  static final EntryService _instance = EntryService._internal();
  factory EntryService() => _instance;

  // API URL - using the same as in other services
  static const String apiBaseUrl = 'http://10.142.40.109:5001';

  // Services
  final AuthService _authService = AuthService();
  final HealthService _healthService = HealthService();

  EntryService._internal();

  // Parse symptoms string into list of Symptom objects
  List<Symptom> _parseSymptoms(String symptomsString) {
    if (symptomsString.isEmpty) return [];

    List<Symptom> symptoms = [];
    // Split by comma for multiple symptoms
    List<String> symptomItems = symptomsString.split(',');
    
    for (String item in symptomItems) {
      item = item.trim();
      if (item.isEmpty) continue;

      // Check if item has format "symptom:severity"
      if (item.contains(':')) {
        List<String> parts = item.split(':');
        if (parts.length == 2) {
          String symptomName = parts[0].trim();
          int severity = int.tryParse(parts[1].trim()) ?? 1;
          symptoms.add(Symptom(symptom: symptomName, severity: severity));
          continue;
        }
      }
      
      // Default to severity 1 if not specified
      symptoms.add(Symptom(symptom: item, severity: 1));
    }

    return symptoms;
  }

  // Parse tags string into list of tags
  List<String> _parseTags(String tagsString) {
    if (tagsString.isEmpty) return [];
    
    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  // Create a new entry with health data
  Future<HealthEntry?> createEntry({
    required int mood,
    required int energyLevel,
    required String symptomsString,
    required String notes,
    required String tagsString,
    DateTime? timestamp,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return null;

    final now = timestamp ?? DateTime.now();
    Map<HealthDataType, dynamic> healthData = {};
    
    // Try to get health data if user has authorized
    if (_healthService.isAuthorized) {
      // Get health data for the day
      final today = DateTime(now.year, now.month, now.day);
      healthData = await _healthService.getHealthData(today, now);
    }
    
    try {
      // Parse symptoms and tags
      final symptoms = _parseSymptoms(symptomsString);
      final tags = _parseTags(tagsString);
      
      // Create entry JSON
      final entryJson = {
        'userId': currentUser.id,
        'mood': mood,
        'energyLevel': energyLevel,
        'symptoms': symptoms.map((s) => s.toJson()).toList(),
        'notes': notes,
        'tags': tags,
        'timestamp': now.toIso8601String(),
        // Add health data if available
        if (healthData.containsKey(HealthDataType.STEPS))
          'steps': healthData[HealthDataType.STEPS],
        if (healthData.containsKey(HealthDataType.ACTIVE_ENERGY_BURNED))
          'activeEnergy': healthData[HealthDataType.ACTIVE_ENERGY_BURNED],
        if (healthData.containsKey(HealthDataType.HEART_RATE))
          'heartRate': healthData[HealthDataType.HEART_RATE],
        if (healthData.containsKey(HealthDataType.SLEEP_IN_BED))
          'sleepMinutes': healthData[HealthDataType.SLEEP_IN_BED],
        // Add all other health data in a map
        'additionalHealthData': {
          for (var type in healthData.keys)
            if (type != HealthDataType.STEPS &&
                type != HealthDataType.ACTIVE_ENERGY_BURNED &&
                type != HealthDataType.HEART_RATE &&
                type != HealthDataType.SLEEP_IN_BED)
              type.name: healthData[type],
        },
      };
      
      // Send to API
      final response = await http.post(
        Uri.parse('$apiBaseUrl/entries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(entryJson),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return HealthEntry.fromJson(data);
      } else {
        print('Error creating entry: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating entry: $e');
      return null;
    }
  }
  
  // Get all entries for current user
  Future<List<HealthEntry>> getUserEntries() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/entries/user/${currentUser.id}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((entry) => HealthEntry.fromJson(entry)).toList();
      } else {
        print('Error getting entries: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting entries: $e');
      return [];
    }
  }
  
  // Get entries for a specific date range
  Future<List<HealthEntry>> getEntriesForDateRange(DateTime start, DateTime end) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/entries/user/${currentUser.id}/range?start=${start.toIso8601String()}&end=${end.toIso8601String()}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((entry) => HealthEntry.fromJson(entry)).toList();
      } else {
        print('Error getting entries: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting entries: $e');
      return [];
    }
  }
}
