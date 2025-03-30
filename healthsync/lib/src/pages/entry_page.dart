import 'package:flutter/material.dart';
import 'package:healthsync/src/models/entry_model.dart';
import 'package:healthsync/src/services/entry_service.dart';
import 'package:healthsync/src/services/health_service.dart';
import 'package:intl/intl.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  final EntryService _entryService = EntryService();
  final HealthService _healthService = HealthService();
  
  bool _isSubmitting = false;
  
  // Default entry data
  Map<String, dynamic> entryData = {
    'mood': 3.0,
    'energyLevel': 3.0,
  };

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
              const Center(
                child: Text(
                  'Add Entry',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Slider(
                    value: entryData['mood'],
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Slider(
                    value: entryData['energyLevel'],
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
                  onPressed: _isSubmitting ? null : _submitEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      )
                    : const Text('Submit Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Handle entry submission with health data
  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // Create entry using our service
      final entry = await _entryService.createEntry(
        mood: entryData['mood'].toInt(),
        energyLevel: entryData['energyLevel'].toInt(),
        symptomsString: _symptomsController.text,
        notes: _notesController.text,
        tagsString: _tagsController.text,
      );
      
      // Show success message
      if (entry != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form
        _resetForm();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit entry. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error submitting entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  // Reset form to defaults
  void _resetForm() {
    _symptomsController.clear();
    _notesController.clear();
    _tagsController.clear();
    
    setState(() {
      entryData['mood'] = 3.0;
      entryData['energyLevel'] = 3.0;
    });
  }
  
  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
