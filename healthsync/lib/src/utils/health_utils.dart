import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:health/health.dart';

final health = Health();

// Define types for native platforms, web doesn't support health data access
final List<HealthDataType> healthDataTypes = kIsWeb ? [] : [
  HealthDataType.STEPS,
  HealthDataType.HEART_RATE,
  HealthDataType.SLEEP_IN_BED,
  HealthDataType.ACTIVE_ENERGY_BURNED,
];

Future<void> configureHealth() async {
  if (!kIsWeb) {
    await health.configure();
  }
}

// Request permissions for health data
Future<void> requestPermissions() async {
  if (!kIsWeb) {
    bool? hasPerms = await health.hasPermissions(healthDataTypes);

    if (hasPerms == null || !hasPerms) {
      await health.requestAuthorization(healthDataTypes);
    }
  }
}

// Fetch total steps for today
Future<int> getTodaySteps() async {
  if (kIsWeb) {
    print("Health data (steps) not available on web.");
    return 0; // Return default value for web
  }

  await requestPermissions();

  DateTime now = DateTime.now();
  DateTime midnight = DateTime(now.year, now.month, now.day);

  try {
    int? steps = await health.getTotalStepsInInterval(midnight, now);
    return steps ?? 0;
  } catch (e) {
    print('Error fetching steps: $e');
    return 0;
  }
}

// Fetch health data for the past week
Future<void> fetchHealthData() async {
  if (kIsWeb) {
    print("Health data fetching not available on web.");
    return; // Exit early for web
  }

  DateTime now = DateTime.now();
  DateTime startDate = now.subtract(const Duration(days: 7));

  try {
    await requestPermissions();

    List<HealthDataPoint>? healthData = await health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: healthDataTypes,
    );

    if (healthData.isNotEmpty) {
      for (var dataPoint in healthData) {
        print('Type: ${dataPoint.type}, Value: ${dataPoint.value}');
      }
    } else {
      print('No health data available for the specified period');
    }
  } catch (e) {
    print('Error fetching health data: $e');
  }
}

