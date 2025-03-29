import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'health_data.dart';

/// Repository for managing health data
class HealthRepository {
  static const String _journalKey = 'journal_entries';
  static const String _sleepKey = 'sleep_data';
  static const String _activityKey = 'activity_data';
  static const String _heartRateKey = 'heart_rate_data';
  
  // In-memory cache for faster access
  List<JournalEntry> _journalEntries = [];
  List<SleepData> _sleepData = [];
  List<ActivityData> _activityData = [];
  List<HeartRateData> _heartRateData = [];
  
  // Singleton pattern
  static final HealthRepository _instance = HealthRepository._internal();
  
  factory HealthRepository() {
    return _instance;
  }
  
  HealthRepository._internal();
  
  /// Initialize the repository with mock data if empty
  Future<void> init() async {
    await _loadData();
    
    // If no data exists, populate with mock data
    if (_journalEntries.isEmpty) {
      await _populateMockData();
    }
  }
  
  /// Load data from persistent storage
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load journal entries
    final journalJson = prefs.getStringList(_journalKey) ?? [];
    _journalEntries = journalJson
        .map((json) => JournalEntry.fromJson(jsonDecode(json)))
        .toList();
    
    // Load sleep data
    final sleepJson = prefs.getStringList(_sleepKey) ?? [];
    _sleepData = sleepJson
        .map((json) => SleepData.fromJson(jsonDecode(json)))
        .toList();
    
    // Load activity data
    final activityJson = prefs.getStringList(_activityKey) ?? [];
    _activityData = activityJson
        .map((json) => ActivityData.fromJson(jsonDecode(json)))
        .toList();
    
    // Load heart rate data
    final heartRateJson = prefs.getStringList(_heartRateKey) ?? [];
    _heartRateData = heartRateJson
        .map((json) => HeartRateData.fromJson(jsonDecode(json)))
        .toList();
  }
  
  /// Save data to persistent storage
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save journal entries
    final journalJson = _journalEntries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList(_journalKey, journalJson);
    
    // Save sleep data
    final sleepJson = _sleepData
        .map((data) => jsonEncode(data.toJson()))
        .toList();
    await prefs.setStringList(_sleepKey, sleepJson);
    
    // Save activity data
    final activityJson = _activityData
        .map((data) => jsonEncode(data.toJson()))
        .toList();
    await prefs.setStringList(_activityKey, activityJson);
    
    // Save heart rate data
    final heartRateJson = _heartRateData
        .map((data) => jsonEncode(data.toJson()))
        .toList();
    await prefs.setStringList(_heartRateKey, heartRateJson);
  }
  
  /// Populate repository with mock data
  Future<void> _populateMockData() async {
    // Mock journal entries
    _journalEntries = [
      JournalEntry(
        id: '1',
        timestamp: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        mood: 3,
        energy: 2,
        symptoms: [SymptomData(name: 'Headache', severity: 6)],
        notes: 'Slept poorly last night. Busy day with back-to-back meetings.',
        tags: ['stress', 'poor_sleep'],
      ),
      JournalEntry(
        id: '2',
        timestamp: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        mood: 3,
        energy: 3,
        symptoms: [],
        notes: 'Feeling better today. Made time for breakfast.',
        tags: [],
      ),
      JournalEntry(
        id: '3',
        timestamp: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        mood: 4,
        energy: 4,
        symptoms: [],
        notes: 'Productive day. Took a walk during lunch break.',
        tags: ['good_day'],
      ),
      JournalEntry(
        id: '4',
        timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        mood: 3,
        energy: 3,
        symptoms: [],
        notes: 'Normal day. Nothing special to report.',
        tags: [],
      ),
      JournalEntry(
        id: '5',
        timestamp: DateTime.now().toIso8601String(),
        mood: 2,
        energy: 2,
        symptoms: [
          SymptomData(name: 'Headache', severity: 7),
          SymptomData(name: 'Fatigue', severity: 6),
        ],
        notes: 'Skipped breakfast, worked through lunch. Headache started around 2pm.',
        tags: ['skipped_meals', 'headache'],
      ),
    ];
    
    // Mock sleep data
    _sleepData = [
      SleepData(
        timestamp: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        duration: 5.5,
        quality: 'poor',
      ),
      SleepData(
        timestamp: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        duration: 6.5,
        quality: 'fair',
      ),
      SleepData(
        timestamp: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        duration: 7.2,
        quality: 'good',
      ),
      SleepData(
        timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        duration: 6.8,
        quality: 'fair',
      ),
      SleepData(
        timestamp: DateTime.now().toIso8601String(),
        duration: 6.1,
        quality: 'fair',
      ),
    ];
    
    // Mock activity data
    _activityData = [
      ActivityData(
        timestamp: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        steps: 4200,
        activeCalories: 180,
      ),
      ActivityData(
        timestamp: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        steps: 6500,
        activeCalories: 240,
      ),
      ActivityData(
        timestamp: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        steps: 9100,
        activeCalories: 320,
      ),
      ActivityData(
        timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        steps: 7200,
        activeCalories: 270,
      ),
      ActivityData(
        timestamp: DateTime.now().toIso8601String(),
        steps: 3800,
        activeCalories: 150,
      ),
    ];
    
    // Mock heart rate data
    _heartRateData = [
      HeartRateData(
        timestamp: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        resting: 72,
      ),
      HeartRateData(
        timestamp: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        resting: 70,
      ),
      HeartRateData(
        timestamp: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        resting: 68,
      ),
      HeartRateData(
        timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        resting: 69,
      ),
      HeartRateData(
        timestamp: DateTime.now().toIso8601String(),
        resting: 74,
      ),
    ];
    
    await _saveData();
  }
  
  // CRUD Operations for Journal Entries
  
  Future<List<JournalEntry>> getJournalEntries() async {
    return _journalEntries;
  }
  
  Future<JournalEntry> addJournalEntry(JournalEntry entry) async {
    _journalEntries.add(entry);
    await _saveData();
    return entry;
  }
  
  // Operations for Sleep Data
  
  Future<List<SleepData>> getSleepData() async {
    return _sleepData;
  }
  
  Future<SleepData> addSleepData(SleepData data) async {
    _sleepData.add(data);
    await _saveData();
    return data;
  }
  
  // Operations for Activity Data
  
  Future<List<ActivityData>> getActivityData() async {
    return _activityData;
  }
  
  Future<ActivityData> addActivityData(ActivityData data) async {
    _activityData.add(data);
    await _saveData();
    return data;
  }
  
  // Operations for Heart Rate Data
  
  Future<List<HeartRateData>> getHeartRateData() async {
    return _heartRateData;
  }
  
  Future<HeartRateData> addHeartRateData(HeartRateData data) async {
    _heartRateData.add(data);
    await _saveData();
    return data;
  }
  
  // Date range filters
  
  Future<List<JournalEntry>> getJournalEntriesInRange(
      DateTime startDate, DateTime endDate) async {
    return _journalEntries.where((entry) {
      final entryDate = DateTime.parse(entry.timestamp);
      return entryDate.isAfter(startDate) && entryDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  Future<List<SleepData>> getSleepDataInRange(
      DateTime startDate, DateTime endDate) async {
    return _sleepData.where((data) {
      final dataDate = DateTime.parse(data.timestamp);
      return dataDate.isAfter(startDate) && dataDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  Future<List<ActivityData>> getActivityDataInRange(
      DateTime startDate, DateTime endDate) async {
    return _activityData.where((data) {
      final dataDate = DateTime.parse(data.timestamp);
      return dataDate.isAfter(startDate) && dataDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  Future<List<HeartRateData>> getHeartRateDataInRange(
      DateTime startDate, DateTime endDate) async {
    return _heartRateData.where((data) {
      final dataDate = DateTime.parse(data.timestamp);
      return dataDate.isAfter(startDate) && dataDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
}
