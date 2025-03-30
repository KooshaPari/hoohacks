import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:healthsync/src/utils/health_utils.dart';
import 'package:http/http.dart' as http; // HTTP package
import 'package:intl/intl.dart'; // For date/time formatting

// --- Configuration ---
// IMPORTANT: Replace '10.0.2.2' with your computer's actual local IP address
// if running on a physical device or different emulator setup.
// You can find your IP using 'ipconfig' (Windows) or 'ifconfig' (macOS/Linux).
const String apiBaseUrl = 'http://10.142.40.109:5001';
// --- End Configuration ---


class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

// TODO: push this data to the DB after each entry
Map<String, dynamic> entryData = {
  'mood': 3,
  'energyLevel': 3,
  'symptoms': '',
  'notes': '',
  'tags': '',
  'date': DateTime.now(),
  'time': TimeOfDay.now(),
};

class _EntryPageState extends State<EntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'Add Entry',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                  'Mood: ${entryData['mood'].toInt()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Slider(
                    value: entryData['mood'].toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: entryData['mood'].toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        entryData['mood'] = value;
                      });
                    }
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Energy Level: ${entryData['energyLevel'].toInt()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Slider(
                    value: entryData['energyLevel'].toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: entryData['energyLevel'].toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        entryData['energyLevel'] = value;
                      });
                    }
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _symptomsController,
                decoration: const InputDecoration(
                  labelText: 'Enter symptoms following this format - Headache:7, Fatigue:5',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter any symptoms';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'How was your day?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Allow labelText to wrap
                ),
                maxLines: 5, // Allow multiple lines
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter any notes you have for today';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (e.g., stress, poor_sleep, skipped_meals)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter any tags you have for today';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Update entryData with latest form values before sending
                      setState(() {
                        entryData['symptoms'] = _symptomsController.text;
                        entryData['notes'] = _notesController.text;
                        entryData['tags'] = _tagsController.text;
                        // Update date/time just before submission
                        entryData['date'] = DateTime.now();
                        entryData['time'] = TimeOfDay.now();
                      });

                      // Call the function to submit data to the API
                      _submitEntryData(context);
                    }
                  },
                  child: const Text('Submit Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to submit data to the backend API
  Future<void> _submitEntryData(BuildContext context) async {
    final url = Uri.parse('$apiBaseUrl/add_entry');
    final headers = {"Content-Type": "application/json"};

    // Prepare data for JSON serialization
    // Format DateTime and TimeOfDay as strings expected by the backend
    final DateTime date = entryData['date'];
    final TimeOfDay time = entryData['time'];
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    // Format TimeOfDay manually (HH:MM) - Ensure leading zeros
    final String formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';


    final body = jsonEncode({
      'mood': entryData['mood'],
      'energyLevel': entryData['energyLevel'],
      'symptoms': entryData['symptoms'],
      'notes': entryData['notes'],
      'tags': entryData['tags'],
      'date': formattedDate, // Send formatted date string
      'time': formattedTime, // Send formatted time string
    });

    // Show loading indicator (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitting entry...')),
    );

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry submitted successfully!'), backgroundColor: Colors.green),
        );
        // Optionally clear the form or navigate away
        // _formKey.currentState?.reset();
        // _symptomsController.clear();
        // _notesController.clear();
        // _tagsController.clear();
        // setState(() {
        //   entryData['mood'] = 3;
        //   entryData['energyLevel'] = 3;
        // });

        // Fetch updated data if needed (e.g., for a summary view)
        // fetchHealthData(); // Assuming this function exists elsewhere
      } else {
        print('API Error: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit entry: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
       // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      print('Network Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: Could not connect to the server. Is it running?'), backgroundColor: Colors.red),
      );
    }
  }
}