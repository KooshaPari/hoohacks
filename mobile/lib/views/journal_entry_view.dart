import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/health_data_controller.dart';
import '../models/health_data.dart';

class JournalEntryView extends StatefulWidget {
  const JournalEntryView({Key? key}) : super(key: key);

  @override
  _JournalEntryViewState createState() => _JournalEntryViewState();
}

class _JournalEntryViewState extends State<JournalEntryView> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _submitting = false;
  List<JournalEntry> _recentEntries = [];
  
  // Form fields
  final _moodController = TextEditingController(text: '3');
  final _energyController = TextEditingController(text: '3');
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  
  int _mood = 3;
  int _energy = 3;
  
  @override
  void initState() {
    super.initState();
    _loadRecentEntries();
  }
  
  @override
  void dispose() {
    _moodController.dispose();
    _energyController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRecentEntries() async {
    setState(() {
      _loading = true;
    });
    
    try {
      final controller = Provider.of<HealthDataController>(context, listen: false);
      await controller.initialize();
      
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final entries = await controller.getJournalEntriesInRange(startDate, endDate);
      
      // Sort by timestamp (newest first)
      entries.sort((a, b) => DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
      
      setState(() {
        _recentEntries = entries;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading entries: $e'))
      );
    }
  }
  
  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _submitting = true;
    });
    
    try {
      final controller = Provider.of<HealthDataController>(context, listen: false);
      
      // Parse symptoms
      final symptoms = <SymptomData>[];
      if (_symptomsController.text.isNotEmpty) {
        final symptomStrings = _symptomsController.text.split(',');
        for (var symptomStr in symptomStrings) {
          symptomStr = symptomStr.trim();
          if (symptomStr.isEmpty) continue;
          
          int severity = 5; // Default severity
          String name = symptomStr;
          
          // Check if severity is specified (format: "Headache:7")
          if (symptomStr.contains(':')) {
            final parts = symptomStr.split(':');
            name = parts[0].trim();
            severity = int.tryParse(parts[1].trim()) ?? 5;
            // Ensure severity is between 1 and 10
            severity = severity.clamp(1, 10);
          }
          
          symptoms.add(SymptomData(name: name, severity: severity));
        }
      }
      
      // Parse tags
      final tags = <String>[];
      if (_tagsController.text.isNotEmpty) {
        // Replace commas with spaces and split by space
        final tagsText = _tagsController.text.replaceAll(',', ' ');
        final tagWords = tagsText.split(' ');
        
        for (var tag in tagWords) {
          tag = tag.trim();
          if (tag.isNotEmpty) {
            tags.add(tag);
          }
        }
      }
      
      // Create journal entry
      final entry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now().toIso8601String(),
        mood: _mood,
        energy: _energy,
        symptoms: symptoms,
        notes: _notesController.text,
        tags: tags,
      );
      
      // Save entry
      await controller.saveJournalEntry(entry);
      
      // Reset form
      _moodController.text = '3';
      _energyController.text = '3';
      _symptomsController.clear();
      _notesController.clear();
      _tagsController.clear();
      
      setState(() {
        _mood = 3;
        _energy = 3;
        _submitting = false;
      });
      
      // Reload entries
      await _loadRecentEntries();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry saved!'))
      );
    } catch (e) {
      setState(() {
        _submitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e'))
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentEntries,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New Entry Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Entry',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'How are you feeling today?',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        
                        // Mood Slider
                        Row(
                          children: [
                            const Text('Mood:'),
                            Expanded(
                              child: Slider(
                                value: _mood.toDouble(),
                                min: 1,
                                max: 5,
                                divisions: 4,
                                label: _mood.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _mood = value.round();
                                    _moodController.text = _mood.toString();
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text('$_mood/5'),
                            ),
                          ],
                        ),
                        
                        // Energy Slider
                        Row(
                          children: [
                            const Text('Energy:'),
                            Expanded(
                              child: Slider(
                                value: _energy.toDouble(),
                                min: 1,
                                max: 5,
                                divisions: 4,
                                label: _energy.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _energy = value.round();
                                    _energyController.text = _energy.toString();
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text('$_energy/5'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Symptoms Input
                        TextFormField(
                          controller: _symptomsController,
                          decoration: const InputDecoration(
                            labelText: 'Symptoms (comma separated, with severity 1-10)',
                            helperText: 'Format: Headache:7, Fatigue:5',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Notes Input
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            helperText: 'How was your day? Any notable events or feelings?',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tags Input
                        TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags',
                            helperText: 'Space or comma separated, e.g., "stress poor_sleep"',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submitEntry,
                            child: _submitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Save Entry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recent Entries
              const Text(
                'Recent Entries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _recentEntries.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No entries yet. Start tracking your daily health!'),
                          ),
                        )
                      : Column(
                          children: _recentEntries.map((entry) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDateTime(entry.timestamp),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.mood,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            Text(' ${entry.mood}/5'),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.bolt,
                                              size: 18,
                                              color: Colors.orange,
                                            ),
                                            Text(' ${entry.energy}/5'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    
                                    if (entry.symptoms.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        children: entry.symptoms.map((s) {
                                          return Chip(
                                            label: Text('${s.name} (${s.severity})'),
                                            backgroundColor: Colors.red.shade100,
                                            visualDensity: VisualDensity.compact,
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                    
                                    const SizedBox(height: 8),
                                    Text(entry.notes),
                                    
                                    if (entry.tags.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        children: entry.tags.map((tag) {
                                          return Chip(
                                            label: Text('#$tag'),
                                            backgroundColor: Colors.grey.shade200,
                                            visualDensity: VisualDensity.compact,
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final date = '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour == 0 ? 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute $period';
    return '$date $time';
  }
}
