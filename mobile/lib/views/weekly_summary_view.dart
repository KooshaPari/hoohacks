import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/health_data_controller.dart';

class WeeklySummaryView extends StatefulWidget {
  const WeeklySummaryView({Key? key}) : super(key: key);

  @override
  _WeeklySummaryViewState createState() => _WeeklySummaryViewState();
}

class _WeeklySummaryViewState extends State<WeeklySummaryView> {
  bool _loading = true;
  Map<String, dynamic>? _summaryData;
  String _narrative = '';
  
  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }
  
  Future<void> _loadSummaryData() async {
    setState(() {
      _loading = true;
    });
    
    try {
      final controller = Provider.of<HealthDataController>(context, listen: false);
      await controller.initialize();
      
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final summary = await controller.getHealthSummary(startDate, endDate);
      final narrative = await controller.getWeeklyNarrative();
      
      setState(() {
        _summaryData = summary;
        _narrative = narrative;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading summary: $e'))
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSummaryData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildSummary(),
    );
  }
  
  Widget _buildSummary() {
    if (_summaryData == null) {
      return const Center(child: Text('No data available'));
    }
    
    final period = _summaryData!['period'];
    final startDate = DateTime.parse(period['start']).toLocal();
    final endDate = DateTime.parse(period['end']).toLocal();
    
    final formattedStartDate = '${startDate.month}/${startDate.day}/${startDate.year}';
    final formattedEndDate = '${endDate.month}/${endDate.day}/${endDate.year}';
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period
            Text(
              '$formattedStartDate - $formattedEndDate',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            
            const SizedBox(height: 16),
            
            // AI-Generated Narrative
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Week in Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_narrative),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Health Metrics Overview
            const Text(
              'Health Metrics Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMetricCard(
                  'Mood',
                  '${_summaryData!['mood']['average']}/5',
                  'Weekly Average',
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Energy',
                  '${_summaryData!['energy']['average']}/5',
                  'Weekly Average',
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Sleep',
                  '${_summaryData!['sleep']['average']} hrs',
                  'Weekly Average',
                  Colors.purple,
                ),
                _buildMetricCard(
                  'Activity',
                  '${_summaryData!['activity']['averageSteps']}',
                  'Avg. Daily Steps',
                  Colors.green,
                ),
                _buildMetricCard(
                  'Heart Rate',
                  '${_summaryData!['heartRate']['averageResting']} bpm',
                  'Avg. Resting HR',
                  Colors.red,
                ),
                _buildMetricCard(
                  'Journal Entries',
                  '${_summaryData!['entries']}',
                  'Days Logged',
                  Colors.teal,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Symptoms Summary
            const Text(
              'Symptoms Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSymptomsSection(),
            
            const SizedBox(height: 24),
            
            // Weekly Trends
            const Text(
              'Weekly Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Chart visualization would appear here in the complete app',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sleep Duration Trend',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text('Sleep Chart Visualization'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Daily Steps Trend',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text('Steps Chart Visualization'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mood & Energy Trend',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text('Mood & Energy Chart Visualization'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricCard(String title, String value, String subtitle, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSymptomsSection() {
    if (_summaryData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available'),
        ),
      );
    }
    
    final symptoms = _summaryData!['symptoms'] as Map<String, dynamic>?;
    
    if (symptoms == null || symptoms.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No symptoms reported this week.'),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: symptoms.entries.map((entry) {
            final name = entry.key;
            final data = entry.value as Map<String, dynamic>;
            final count = data['count'] as int;
            final avgSeverity = data['avgSeverity'] as double;
            
            return ListTile(
              title: Text(name),
              subtitle: Text('Average severity: $avgSeverity/10'),
              trailing: Text('$count day${count != 1 ? 's' : ''}'),
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Text('$count'),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
