import 'package:flutter/foundation.dart';
import '../models/health_data.dart';
import '../models/health_repository.dart';
import '../services/health_service.dart';
import '../services/api_service.dart';

/// Controller in the MCP pattern - manages data flow between models and presenters
class HealthDataController extends ChangeNotifier {
  final HealthRepository _repository = HealthRepository();
  final HealthService _healthService = HealthService();
  final ApiService _apiService = ApiService();
  
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Initialize the controller
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    
    try {
      // Initialize the repository
      await _repository.init();
      
      // Request HealthKit authorization
      final authorized = await _healthService.requestAuthorization();
      
      if (authorized) {
        // If authorized, sync recent health data
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 30));
        await _healthService.syncHealthData(startDate, now);
      }
      
      _isInitialized = true;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize health data: $e');
    }
  }
  
  /// Get journal entries for a specific date range
  Future<List<JournalEntry>> getJournalEntriesInRange(
      DateTime startDate, DateTime endDate) async {
    return await _repository.getJournalEntriesInRange(startDate, endDate);
  }
  
  /// Get health data summary for a specific date range
  Future<Map<String, dynamic>> getHealthSummary(
      DateTime startDate, DateTime endDate) async {
    final journalEntries = await _repository.getJournalEntriesInRange(startDate, endDate);
    final sleepData = await _repository.getSleepDataInRange(startDate, endDate);
    final activityData = await _repository.getActivityDataInRange(startDate, endDate);
    final heartRateData = await _repository.getHeartRateDataInRange(startDate, endDate);
    
    // Calculate summary statistics
    final moodAverage = _calculateAverage(journalEntries.map((e) => e.mood.toDouble()).toList());
    final energyAverage = _calculateAverage(journalEntries.map((e) => e.energy.toDouble()).toList());
    final symptomCounts = _countSymptoms(journalEntries);
    final sleepAverage = _calculateAverage(sleepData.map((e) => e.duration).toList());
    final stepsAverage = _calculateAverage(activityData.map((e) => e.steps.toDouble()).toList());
    final restingHRAverage = _calculateAverage(heartRateData.map((e) => e.resting.toDouble()).toList());
    
    // Format summary
    return {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String()
      },
      'entries': journalEntries.length,
      'mood': {
        'average': moodAverage
      },
      'energy': {
        'average': energyAverage
      },
      'symptoms': symptomCounts,
      'sleep': {
        'average': sleepAverage
      },
      'activity': {
        'averageSteps': stepsAverage.toInt()
      },
      'heartRate': {
        'averageResting': restingHRAverage.toInt()
      }
    };
  }
  
  /// Get pattern analysis for a specific symptom
  Future<Map<String, dynamic>> getPatternAnalysis(
      String symptom, DateTime startDate, DateTime endDate) async {
    final journalEntries = await _repository.getJournalEntriesInRange(startDate, endDate);
    final sleepData = await _repository.getSleepDataInRange(startDate, endDate);
    final activityData = await _repository.getActivityDataInRange(startDate, endDate);
    
    // Separate entries with and without the symptom
    final symptomDays = journalEntries.where((entry) => 
        entry.symptoms.any((s) => s.name.toLowerCase() == symptom.toLowerCase())
    ).toList();
    
    final nonSymptomDays = journalEntries.where((entry) => 
        !entry.symptoms.any((s) => s.name.toLowerCase() == symptom.toLowerCase())
    ).toList();
    
    // Calculate averages for both groups
    final symptomSleepAvg = _calculateAverageForDays(symptomDays, sleepData, (data) => data.duration);
    final nonSymptomSleepAvg = _calculateAverageForDays(nonSymptomDays, sleepData, (data) => data.duration);
    
    final symptomStepsAvg = _calculateAverageForDays(symptomDays, activityData, (data) => data.steps.toDouble());
    final nonSymptomStepsAvg = _calculateAverageForDays(nonSymptomDays, activityData, (data) => data.steps.toDouble());
    
    // Get tags frequency
    final symptomTags = _getTagsFrequency(symptomDays);
    final nonSymptomTags = _getTagsFrequency(nonSymptomDays);
    
    return {
      'symptom': symptom,
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String()
      },
      'symptomDaysCount': symptomDays.length,
      'nonSymptomDaysCount': nonSymptomDays.length,
      'comparisons': {
        'sleep': {
          'symptomDaysAvg': symptomSleepAvg,
          'nonSymptomDaysAvg': nonSymptomSleepAvg,
          'difference': nonSymptomSleepAvg - symptomSleepAvg
        },
        'activity': {
          'symptomDaysAvg': symptomStepsAvg.toInt(),
          'nonSymptomDaysAvg': nonSymptomStepsAvg.toInt(),
          'difference': (nonSymptomStepsAvg - symptomStepsAvg).toInt()
        }
      },
      'tags': {
        'symptomDays': symptomTags,
        'nonSymptomDays': nonSymptomTags
      }
    };
  }
  
  /// Get the weekly narrative using AI
  Future<String> getWeeklyNarrative() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final summary = await getHealthSummary(startDate, endDate);
      
      // Call the API service to get AI-generated narrative
      return await _apiService.generateWeeklyNarrative(summary);
    } catch (e) {
      return 'Unable to generate weekly narrative. Please try again later.';
    }
  }
  
  /// Get doctor visit summary
  Future<Map<String, dynamic>> getDoctorVisitSummary() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final summary = await getHealthSummary(startDate, endDate);
      final journalEntries = await _repository.getJournalEntriesInRange(startDate, endDate);
      
      // Get all unique symptoms
      final symptoms = <String, Map<String, dynamic>>{};
      
      for (var entry in journalEntries) {
        for (var symptom in entry.symptoms) {
          if (!symptoms.containsKey(symptom.name)) {
            symptoms[symptom.name] = {
              'occurrences': 0,
              'totalSeverity': 0
            };
          }
          symptoms[symptom.name]?['occurrences'] = (symptoms[symptom.name]?['occurrences'] ?? 0) + 1;
          symptoms[symptom.name]?['totalSeverity'] = (symptoms[symptom.name]?['totalSeverity'] ?? 0) + symptom.severity;
        }
      }
      
      // Calculate average severity
      for (var name in symptoms.keys) {
        final totalSeverity = symptoms[name]?['totalSeverity'] ?? 0;
        final occurrences = symptoms[name]?['occurrences'] ?? 0;
        if (occurrences > 0) {
          symptoms[name]?['avgSeverity'] = (totalSeverity / occurrences * 10).round() / 10;
        }
      }
      
      // Get AI insights about patterns
      final patterns = await _apiService.generateDoctorVisitInsights(summary);
      
      // Format doctor visit summary
      return {
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String()
        },
        'keySymptoms': symptoms.entries.map((e) => {
          'name': e.key,
          'occurrences': e.value['occurrences'],
          'avgSeverity': e.value['avgSeverity'],
        }).toList(),
        'overallPatterns': patterns['overallPatterns'],
        'questions': patterns['questions'],
      };
    } catch (e) {
      _setError('Failed to generate doctor visit summary: $e');
      return {
        'period': {
          'start': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'end': DateTime.now().toIso8601String()
        },
        'keySymptoms': [],
        'overallPatterns': [],
        'questions': [],
      };
    }
  }
  
  /// Save a journal entry
  Future<JournalEntry> saveJournalEntry(JournalEntry entry) async {
    return await _repository.addJournalEntry(entry);
  }
  
  // Helper methods
  
  /// Calculate average for a list of values
  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    final sum = values.reduce((a, b) => a + b);
    return double.parse((sum / values.length).toStringAsFixed(1));
  }
  
  /// Count symptoms from journal entries
  Map<String, Map<String, dynamic>> _countSymptoms(List<JournalEntry> entries) {
    final symptoms = <String, Map<String, dynamic>>{};
    
    for (var entry in entries) {
      for (var symptom in entry.symptoms) {
        if (!symptoms.containsKey(symptom.name)) {
          symptoms[symptom.name] = {
            'count': 0,
            'totalSeverity': 0
          };
        }
        symptoms[symptom.name]?['count'] = (symptoms[symptom.name]?['count'] ?? 0) + 1;
        symptoms[symptom.name]?['totalSeverity'] = (symptoms[symptom.name]?['totalSeverity'] ?? 0) + symptom.severity;
      }
    }
    
    // Calculate average severity
    for (var name in symptoms.keys) {
      final totalSeverity = symptoms[name]?['totalSeverity'] ?? 0;
      final count = symptoms[name]?['count'] ?? 0;
      if (count > 0) {
        symptoms[name]?['avgSeverity'] = (totalSeverity / count * 10).round() / 10;
      }
    }
    
    return symptoms;
  }
  
  /// Calculate average for metric data on specific days
  double _calculateAverageForDays<T>(
      List<JournalEntry> days, 
      List<T> metricData,
      double Function(T) metricExtractor) {
    if (days.isEmpty) return 0;
    
    final dayTimestamps = days.map((day) => _getDateString(DateTime.parse(day.timestamp))).toSet();
    
    final relevantMetrics = metricData.where((metric) {
      if (metric is SleepData) {
        return dayTimestamps.contains(_getDateString(DateTime.parse(metric.timestamp)));
      } else if (metric is ActivityData) {
        return dayTimestamps.contains(_getDateString(DateTime.parse(metric.timestamp)));
      } else if (metric is HeartRateData) {
        return dayTimestamps.contains(_getDateString(DateTime.parse(metric.timestamp)));
      }
      return false;
    }).toList();
    
    if (relevantMetrics.isEmpty) return 0;
    
    final values = relevantMetrics.map(metricExtractor).toList();
    return _calculateAverage(values);
  }
  
  /// Get the frequency of tags in journal entries
  Map<String, int> _getTagsFrequency(List<JournalEntry> entries) {
    final tags = <String, int>{};
    
    for (var entry in entries) {
      for (var tag in entry.tags) {
        tags[tag] = (tags[tag] ?? 0) + 1;
      }
    }
    
    return tags;
  }
  
  /// Get date string (YYYY-MM-DD) from DateTime
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }
}
