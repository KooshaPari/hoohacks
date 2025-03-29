import 'package:flutter/material.dart';
import 'package:healthsync/src/components/graph.dart';
import 'package:healthsync/src/components/data_card.dart';
import 'package:healthsync/src/components/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget insightGraph = Container(); // placeholder, update if graph is available

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // const SizedBox(height: 8),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.insights,
                            size: 40,
                            color: Colors.purple,
                          ),
                          SizedBox(width: 10),
                          insightGraph, // optional, if it exists then update it to be an actual graph, else don't keep it
                          Text(
                            'Your Monthly Insights',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'At a Glance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Over the last month, you\'ve averaged:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              DataCard(
                icon: Icons.directions_run,
                title: 'Steps',
                value: 10000,
                unit: 'steps',
                color: Colors.green,
              ),
              DataCard(
                icon: Icons.favorite,
                title: 'Heart Rate',
                value: 72,
                unit: 'bpm',
                color: Colors.red,
              ),
              DataCard(
                icon: Icons.bedtime,
                title: 'Sleep',
                value: 7,
                unit: 'hours',
                color: Colors.blue,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
