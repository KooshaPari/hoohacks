import 'package:flutter/material.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

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
                  labelText: 'Headache:7, Fatigue:5',
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
                      setState(() {
                        entryData['symptoms'] = _symptomsController.text;
                        entryData['notes'] = _notesController.text;
                        entryData['tags'] = _tagsController.text;
                        print(entryData);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entry submitted')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}