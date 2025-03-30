import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async'; // Import Completer
import 'package:health/health.dart';
// Keep import without alias for static calls
import 'package:health_kit_reporter/health_kit_reporter.dart'; 
import 'package:healthsync/src/models/user_model.dart';
import 'package:healthsync/src/services/auth_service.dart';
import 'package:healthsync/src/services/user_service.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;

  // Services
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // Health package instance
  final Health _health = Health();

  // No instance variable needed for health_kit_reporter

  // Define standard health data types (from health package)
  final List<HealthDataType> _healthDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
  ];

  // Store authorization status
  bool _isAuthorized = false;

  HealthService._internal();

  // Initialize health services and check authorization
  Future<void> initialize() async {
    // Skip on web, health data APIs aren't available
    if (kIsWeb) return;

    try {
      // Configure the health package
      await _health.configure();
      
      // No instance initialization needed
      
      // Check if current user has already given consent in our database
      await _checkPersistedConsent();
      
    } catch (e) {
      print('Error initializing HealthService: $e');
    }
  }

  // Check if the user has already given consent in our database
  Future<void> _checkPersistedConsent() async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Removed the call to _checkHealthKitPermissions as it was causing issues.
    // Relying on requestHealthPermissions to handle authorization checks.
    // if (Platform.isIOS && currentUser.hasHealthkitConsent) {
    //   // For iOS, check if HealthKit permissions are still valid
    //   await _checkHealthKitPermissions();
    // } else 
    if (Platform.isAndroid && currentUser.hasGoogleFitConsent) {
      // For Android, check if Health Connect permissions are still valid
      await _checkHealthConnectPermissions();
    }
  }

  // Request health data permissions based on platform
  Future<bool> requestHealthPermissions() async {
    if (kIsWeb) return false;
    
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    bool permissionsGranted = false;

    try {
      if (Platform.isIOS) {
        permissionsGranted = await _requestHealthKitPermissions();
        
        // Update user's consent status in database
        if (permissionsGranted) {
          await _userService.updateHealthConsent(
            currentUser.id, 
            hasHealthkitConsent: true
          );
        }
      } else if (Platform.isAndroid) {
        permissionsGranted = await _requestHealthConnectPermissions();
        
        // Update user's consent status in database
        if (permissionsGranted) {
          await _userService.updateHealthConsent(
            currentUser.id, 
            hasGoogleFitConsent: true
          );
        }
      }
      
      _isAuthorized = permissionsGranted;
      return permissionsGranted;
    } catch (e) {
      print('Error requesting health permissions: $e');
      return false;
    }
  }

  // Removed _checkHealthKitPermissions method

  // Check if Health Connect permissions are valid on Android
  Future<void> _checkHealthConnectPermissions() async {
    if (!Platform.isAndroid) return;

    try {
      // Using health package to check permissions
      final hasPermissions = await _health.hasPermissions(_healthDataTypes);
      _isAuthorized = hasPermissions == true;
    } catch (e) {
      print('Error checking Health Connect permissions: $e');
      _isAuthorized = false;
    }
  }

  // Request HealthKit permissions on iOS using static method and string IDs (for v2.3.1)
  Future<bool> _requestHealthKitPermissions() async {
    if (!Platform.isIOS) return false; 

    try {
      // Define the read and write types as strings
       const List<String> readTypes = [
        'HKQuantityTypeIdentifierStepCount',
        'HKQuantityTypeIdentifierHeartRate',
        'HKQuantityTypeIdentifierActiveEnergyBurned',
        'HKCategoryTypeIdentifierSleepAnalysis',
        'HKQuantityTypeIdentifierBloodGlucose',
        'HKQuantityTypeIdentifierBloodOxygenSaturation', 
        'HKQuantityTypeIdentifierBloodPressureSystolic',
        'HKQuantityTypeIdentifierBloodPressureDiastolic',
        'HKQuantityTypeIdentifierBodyTemperature',
        'HKQuantityTypeIdentifierBodyMass', 
        'HKQuantityTypeIdentifierHeight',
      ];

      const List<String> writeTypes = [
        'HKQuantityTypeIdentifierStepCount',
        'HKQuantityTypeIdentifierActiveEnergyBurned',
        'HKQuantityTypeIdentifierHeartRate',
      ];

      // Request authorization using static method and string types
      final bool isAuthorized = await HealthKitReporter.requestAuthorization(readTypes, writeTypes);
      return isAuthorized;
    } catch (e) {
      print('Error requesting HealthKit permissions: $e');
      return false;
    }
  }

  // Request Health Connect permissions on Android
  Future<bool> _requestHealthConnectPermissions() async {
    if (!Platform.isAndroid) return false;

    try {
      // Request authorization using health package
      final isAuthorized = await _health.requestAuthorization(_healthDataTypes);
      return isAuthorized;
    } catch (e) {
      print('Error requesting Health Connect permissions: $e');
      return false;
    }
  }

  // Get health data for a specific time period
  Future<Map<HealthDataType, dynamic>> getHealthData(DateTime startDate, DateTime endDate) async {
    if (kIsWeb) return {};
    if (!_isAuthorized) await requestHealthPermissions();
    if (!_isAuthorized) return {};

    Map<HealthDataType, dynamic> healthData = {};

    try {
      // Get steps data
      int? steps = await _health.getTotalStepsInInterval(startDate, endDate);
      if (steps != null) {
        healthData[HealthDataType.STEPS] = steps;
      }

      // Get all other health data
      List<HealthDataPoint> healthDataPoints = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: _healthDataTypes,
      );

      // Process the data points
      for (HealthDataType type in _healthDataTypes) {
        if (type == HealthDataType.STEPS) continue; // Already handled

        // Filter data points by type
        List<HealthDataPoint> dataPoints = healthDataPoints
            .where((point) => point.type == type)
            .toList();

        if (dataPoints.isNotEmpty) {
          // For heart rate, calculate average, ensuring value is NumericHealthValue
          if (type == HealthDataType.HEART_RATE) {
            double sum = 0;
            int count = 0;
            for (var point in dataPoints) {
              if (point.value is NumericHealthValue) {
                 sum += (point.value as NumericHealthValue).numericValue.toDouble();
                 count++;
              }
            }
             if (count > 0) {
               healthData[type] = sum / count;
             }
          }
          // For sleep, calculate total time
          else if (type == HealthDataType.SLEEP_IN_BED) {
            int totalMinutes = 0;
            for (var point in dataPoints) {
              final duration = point.dateTo.difference(point.dateFrom);
              totalMinutes += duration.inMinutes;
            }
            healthData[type] = totalMinutes;
          }
          // For other numeric types, use the latest value, ensuring it's numeric
          else if (dataPoints.last.value is NumericHealthValue) {
             healthData[type] = (dataPoints.last.value as NumericHealthValue).numericValue;
          }
          // Handle other potential types if needed, otherwise they are skipped
        }
      }

      return healthData;
    } catch (e) {
      print('Error fetching health data: $e');
      return {};
    }
  }

  // Get today's health data
  Future<Map<HealthDataType, dynamic>> getTodayHealthData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return await getHealthData(today, now);
  }

  // Check if user has given health data permissions
  bool get isAuthorized => _isAuthorized;
}
