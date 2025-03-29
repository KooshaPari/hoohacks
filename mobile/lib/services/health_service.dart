import 'package:health/health.dart';
import 'package:intl/intl.dart';
import '../models/health_data.dart';

/// Service to interact with Apple HealthKit/Google Fit
class HealthService {
  final HealthFactory _health = HealthFactory();
  
  // Available data types we're interested in
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
  ];
  
  /// Request permission to access health data
  Future<bool> requestAuthorization() async {
    try {
      return await _health.requestAuthorization(_dataTypes);
    } catch (e) {
      print('Error requesting HealthKit authorization: $e');
      return false;
    }
  }
  
  /// Fetch steps data for a specific date range
  Future<List<ActivityData>> fetchStepsData(DateTime startDate, DateTime endDate) async {
    try {
      final steps = await _health.getHealthDataFromTypes(
        startDate, 
        endDate,
        [HealthDataType.STEPS],
      );
      
      // Group by day and sum up steps
      final Map<String, int> dailySteps = {};
      
      for (var step in steps) {
        final dateKey = DateFormat('yyyy-MM-dd').format(step.dateFrom);
        dailySteps[dateKey] = (dailySteps[dateKey] ?? 0) + (int.tryParse(step.value.toString()) ?? 0);
      }
      
      // Fetch active energy data
      final activeEnergy = await _health.getHealthDataFromTypes(
        startDate, 
        endDate,
        [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      
      // Group by day and sum up calories
      final Map<String, int> dailyCalories = {};
      
      for (var energy in activeEnergy) {
        final dateKey = DateFormat('yyyy-MM-dd').format(energy.dateFrom);
        dailyCalories[dateKey] = (dailyCalories[dateKey] ?? 0) + (int.tryParse(energy.value.toString()) ?? 0);
      }
      
      // Combine into ActivityData objects
      final List<ActivityData> result = [];
      
      for (var dateKey in dailySteps.keys) {
        result.add(ActivityData(
          timestamp: '$dateKey' 'T00:00:00Z',
          steps: dailySteps[dateKey] ?? 0,
          activeCalories: dailyCalories[dateKey] ?? 0,
        ));
      }
      
      return result;
    } catch (e) {
      print('Error fetching steps data: $e');
      return [];
    }
  }
  
  /// Fetch sleep data for a specific date range
  Future<List<SleepData>> fetchSleepData(DateTime startDate, DateTime endDate) async {
    try {
      final sleepData = await _health.getHealthDataFromTypes(
        startDate, 
        endDate,
        [
          HealthDataType.SLEEP_IN_BED,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
        ],
      );
      
      // Process sleep data by day
      final Map<String, Map<String, dynamic>> dailySleep = {};
      
      for (var sleep in sleepData) {
        final dateKey = DateFormat('yyyy-MM-dd').format(sleep.dateFrom);
        
        if (!dailySleep.containsKey(dateKey)) {
          dailySleep[dateKey] = {
            'asleepMinutes': 0,
            'inBedMinutes': 0,
            'awakeMinutes': 0,
          };
        }
        
        final durationMinutes = sleep.dateTo.difference(sleep.dateFrom).inMinutes;
        
        if (sleep.type == HealthDataType.SLEEP_ASLEEP) {
          dailySleep[dateKey]?['asleepMinutes'] = (dailySleep[dateKey]?['asleepMinutes'] ?? 0) + durationMinutes;
        } else if (sleep.type == HealthDataType.SLEEP_IN_BED) {
          dailySleep[dateKey]?['inBedMinutes'] = (dailySleep[dateKey]?['inBedMinutes'] ?? 0) + durationMinutes;
        } else if (sleep.type == HealthDataType.SLEEP_AWAKE) {
          dailySleep[dateKey]?['awakeMinutes'] = (dailySleep[dateKey]?['awakeMinutes'] ?? 0) + durationMinutes;
        }
      }
      
      // Convert to SleepData objects
      final List<SleepData> result = [];
      
      for (var dateKey in dailySleep.keys) {
        final data = dailySleep[dateKey];
        if (data != null) {
          final asleepHours = (data['asleepMinutes'] ?? 0) / 60.0;
          
          // Basic sleep quality assessment
          String quality = 'poor';
          if (asleepHours >= 7.0) {
            quality = 'good';
          } else if (asleepHours >= 6.0) {
            quality = 'fair';
          }
          
          result.add(SleepData(
            timestamp: '$dateKey' 'T00:00:00Z',
            duration: double.parse(asleepHours.toStringAsFixed(1)),
            quality: quality,
          ));
        }
      }
      
      return result;
    } catch (e) {
      print('Error fetching sleep data: $e');
      return [];
    }
  }
  
  /// Fetch heart rate data for a specific date range
  Future<List<HeartRateData>> fetchHeartRateData(DateTime startDate, DateTime endDate) async {
    try {
      final heartRateData = await _health.getHealthDataFromTypes(
        startDate, 
        endDate,
        [HealthDataType.HEART_RATE],
      );
      
      // Group by day and calculate average resting heart rate
      final Map<String, List<double>> dailyHeartRates = {};
      
      for (var heartRate in heartRateData) {
        final dateKey = DateFormat('yyyy-MM-dd').format(heartRate.dateFrom);
        
        if (!dailyHeartRates.containsKey(dateKey)) {
          dailyHeartRates[dateKey] = [];
        }
        
        dailyHeartRates[dateKey]?.add(double.tryParse(heartRate.value.toString()) ?? 0);
      }
      
      // Convert to HeartRateData objects
      final List<HeartRateData> result = [];
      
      for (var dateKey in dailyHeartRates.keys) {
        final rates = dailyHeartRates[dateKey];
        if (rates != null && rates.isNotEmpty) {
          // Calculate average heart rate
          final avg = rates.reduce((a, b) => a + b) / rates.length;
          
          result.add(HeartRateData(
            timestamp: '$dateKey' 'T00:00:00Z',
            resting: avg.round(),
          ));
        }
      }
      
      return result;
    } catch (e) {
      print('Error fetching heart rate data: $e');
      return [];
    }
  }
  
  /// Sync all health data for a specific date range
  Future<void> syncHealthData(DateTime startDate, DateTime endDate) async {
    // Implementation would integrate with HealthRepository to store the data
  }
}
