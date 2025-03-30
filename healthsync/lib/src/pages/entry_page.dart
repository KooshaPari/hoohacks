import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:healthsync/src/utils/health_utils.dart';
import 'package:http/http.dart' as http; // HTTP package
import 'package:intl/intl.dart'; // For date/time formatting
import 'dart:developer' as developer; // For logging

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
  bool _noSymptoms = false; // State variable for the checkbox

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _symptomsController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
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
              CheckboxListTile(
                title: const Text("I have no symptoms today"),
                value: _noSymptoms,
                onChanged: (bool? value) {
                  setState(() {
                    _noSymptoms = value ?? false;
                    if (_noSymptoms) {
                      _symptomsController.clear(); // Clear symptoms if checkbox is checked
                      // Optionally, trigger validation again if needed, though clearing might suffice
                      _formKey.currentState?.validate();
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
              ),
              TextFormField(
                controller: _symptomsController,
                enabled: !_noSymptoms, // Disable field if checkbox is checked
                decoration: InputDecoration(
                  labelText: _noSymptoms ? 'No symptoms entered' : 'Symptoms (e.g., Headache:7, Fatigue:5)',
                  border: const OutlineInputBorder(),
                  filled: _noSymptoms, // Visually indicate disabled state
                  fillColor: _noSymptoms ? Colors.grey[200] : null,
                ),
                validator: (value) {
                  if (_noSymptoms) {
                    return null; // No validation needed if checkbox is checked
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please enter symptoms or check "No symptoms"';
                  }
                  // Validation for format: <symptom>:<severity 1-10>, comma-separated
                  final symptomPairs = value.split(',');
                  for (var pair in symptomPairs) {
                    final trimmedPair = pair.trim();
                    if (trimmedPair.isEmpty) continue; // Allow trailing commas or empty segments

                    final parts = trimmedPair.split(':');
                    if (parts.length != 2) {
                      return 'Invalid format: Use "Symptom:Severity" (e.g., "Headache:7")';
                    }
                    final symptomName = parts[0].trim();
                    final severityString = parts[1].trim();
                    if (symptomName.isEmpty) {
                       return 'Invalid format: Symptom name cannot be empty';
                    }
                    final severity = int.tryParse(severityString);
                    if (severity == null || severity < 1 || severity > 10) {
                      return 'Severity must be a number between 1 and 10 (found: "$severityString" for "$symptomName")';
                    }
                  }
                  return null; // Validation passed
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
                    // Validate first
                    if (_formKey.currentState!.validate()) {
                      // Update entryData with latest form values before sending
                      setState(() {
                        // Symptoms are handled in _submitEntryData based on _noSymptoms
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

    // Prepare symptoms data based on checkbox state
    dynamic symptomsData;
    if (_noSymptoms) {
      symptomsData = []; // Send empty list if no symptoms
    } else {
      // Parse the symptoms string into a list of maps
      final symptomsString = _symptomsController.text;
      final symptomPairs = symptomsString.split(',');
      symptomsData = symptomPairs
          .map((pair) {
            final trimmedPair = pair.trim();
            if (trimmedPair.isEmpty) return null; // Handle empty segments

            final parts = trimmedPair.split(':');
            if (parts.length == 2) {
              final symptomName = parts[0].trim();
              final severity = int.tryParse(parts[1].trim());
              if (symptomName.isNotEmpty && severity != null && severity >= 1 && severity <= 10) {
                return {'symptom': symptomName, 'severity': severity};
              }
            }
            // Log invalid parts if necessary, but filter them out
            developer.log('Invalid symptom part ignored: "$trimmedPair"', name: 'EntryPage');
            return null;
          })
          .where((item) => item != null) // Filter out nulls (invalid/empty parts)
          .toList();
    }

    final body = jsonEncode({
      'mood': entryData['mood'],
      'energyLevel': entryData['energyLevel'],
      'symptoms': symptomsData, // Send parsed list or empty list
      'notes': entryData['notes'],
      'tags': entryData['tags'], // Assuming tags remain a comma-separated string for now
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