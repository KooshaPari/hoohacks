import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you might fetch this dynamically from pubspec.yaml
    const String appVersion = '1.0.0'; // Placeholder version

    return Scaffold(
      appBar: AppBar(
        title: const Text('About HealthSync'),
        backgroundColor: Colors.green, // Consistent AppBar color
        titleTextStyle: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set back button color to white
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                'HealthSync',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Version: $appVersion', // Use the constant here
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              Text(
                'Your personal health tracking companion.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}