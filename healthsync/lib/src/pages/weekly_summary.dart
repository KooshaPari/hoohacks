import 'package:flutter/material.dart';
import 'package:healthsync/src/components/graph.dart';

class WeeklySummary extends StatefulWidget {
  const WeeklySummary({super.key});

  @override
  State<WeeklySummary> createState() => _WeeklySummaryState();
}

enum HealthData {
  sleep,
  calories,
  steps,
  heartRate,
}

// get a graph for each type of data
// TODO: make a way to update this/integrate with DB
Map<HealthData, List<double>> healthData = {
  HealthData.sleep: [6.5, 7.0, 8.0, 5.5, 6.0, 7.5, 10.0],
  HealthData.calories: [450, 520, 600, 480, 500, 550, 700],
  HealthData.steps: [6840, 5930, 10500, 8550, 7200, 9000, 12000],
  HealthData.heartRate: [72, 75, 80, 68, 70, 78, 85],
};

class _WeeklySummaryState extends State<WeeklySummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              WeeklyGraph(
                title: 'Sleep',
                values: healthData[HealthData.sleep]!,
                color: Colors.lightBlue,
              ),
              WeeklyGraph(
                title: 'Calories',
                values: healthData[HealthData.calories]!,
                color: Colors.red,
              ),
              WeeklyGraph(
                title: 'Steps',
                values: healthData[HealthData.steps]!,
                color: Colors.orange,
              ),
              WeeklyGraph(
                title: 'Heart Rate',
                values: healthData[HealthData.heartRate]!,
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}