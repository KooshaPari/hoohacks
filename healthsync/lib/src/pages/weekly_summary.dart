import 'package:flutter/material.dart';
import 'package:healthsync/src/components/graph.dart';

class WeeklySummary extends StatefulWidget {
  const WeeklySummary({super.key});

  @override
  State<WeeklySummary> createState() => _WeeklySummaryState();
}

class _WeeklySummaryState extends State<WeeklySummary> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              WeeklyGraph(
                title: 'Sleep',
                values: [6.5, 7.0, 8.0, 5.5, 6.0, 7.5, 10.0],
                color: Colors.lightBlue,
              ),
              WeeklyGraph(
                title: 'Calories',
                values: [450, 520, 600, 480, 500, 550, 700],
                color: Colors.red,
              ),
              WeeklyGraph(
                title: 'Steps',
                values: [6840, 5930, 10500, 8550, 7200, 9000, 12000],
                color: Colors.orange,
              ),
              WeeklyGraph(
                title: 'Heart Rate',
                values: [72, 75, 80, 68, 70, 78, 85],
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}