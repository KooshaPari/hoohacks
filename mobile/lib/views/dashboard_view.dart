import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/health_data_controller.dart';
import '../presenters/dashboard_presenter.dart';
import '../models/health_data.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _loading = true;
  Map<String, dynamic>? _dashboardData;
  late DashboardPresenter _presenter;
  
  @override
  void initState() {
    super.initState();
    _presenter = DashboardPresenter(
      Provider.of<HealthDataController>(context, listen: false)
    );
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    
    try {
      final data = await _presenter.getDashboardData();
      setState(() {
        _dashboardData = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e'))
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthSync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(),
    );
  }
  
  Widget _buildDashboard() {
    if (_dashboardData == null) {
      return const Center(child: Text('No data available'));
    }
    
    final summary = _dashboardData!['summary'];
    final recentEntries = _dashboardData!['recentEntries'] as List<dynamic>;
    final weeklyNarrative = _dashboardData!['weeklyNarrative'] as String;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Narrative
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(weeklyNarrative),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to weekly summary
                        // In a real app, we would use Navigator.push()
                      },
                      child: const Text('View Full Weekly Summary'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Stats
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  'Mood',
                  '${summary['mood']['average']}/5',
                  'Weekly Average',
                  Colors.blue,
                ),
                _buildStatCard(
                  'Energy',
                  '${summary['energy']['average']}/5',
                  'Weekly Average',
                  Colors.orange,
                ),
                _buildStatCard(
                  'Sleep',
                  '${summary['sleep']['average']} hrs',
                  'Weekly Average',
                  Colors.purple,
                ),
                _buildStatCard(
                  'Activity',
                  '${summary['activity']['averageSteps']}',
                  'Avg. Daily Steps',
                  Colors.green,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recent Journal Entries
            const Text(
              'Recent Journal Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            recentEntries.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No recent entries. Start journaling to track your health!'),
                    ),
                  )
                : Column(
                    children: recentEntries.map<Widget>((entry) {
                      final typedEntry = JournalEntry(
                        id: entry['id'],
                        timestamp: entry['timestamp'],
                        mood: entry['mood'],
                        energy: entry['energy'],
                        symptoms: (entry['symptoms'] as List<dynamic>)
                          .map((s) => SymptomData(
                            name: s['name'],
                            severity: s['severity'],
                          ))
                          .toList(),
                        notes: entry['notes'],
                        tags: (entry['tags'] as List<dynamic>)
                          .map((t) => t.toString())
                          .toList(),
                      );
                      
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
                                    _presenter.formatDate(typedEntry.timestamp),
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
                                      Text(' ${typedEntry.mood}/5'),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.bolt,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      Text(' ${typedEntry.energy}/5'),
                                    ],
                                  ),
                                ],
                              ),
                              
                              if (typedEntry.symptoms.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: typedEntry.symptoms.map((s) {
                                    return Chip(
                                      label: Text('${s.name} (${s.severity})'),
                                      backgroundColor: Colors.red.shade100,
                                      visualDensity: VisualDensity.compact,
                                    );
                                  }).toList(),
                                ),
                              ],
                              
                              const SizedBox(height: 8),
                              Text(typedEntry.notes),
                              
                              if (typedEntry.tags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: typedEntry.tags.map((tag) {
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
            
            const SizedBox(height: 16),
            
            // Quick Links
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuickLink(
                    context,
                    'Explore Symptom Patterns',
                    'Analyze correlations between symptoms and lifestyle',
                    Colors.teal,
                    Icons.analytics,
                    () {
                      // Navigate to pattern analysis
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickLink(
                    context,
                    'Prepare for Doctor Visit',
                    'Generate a summary to share with your doctor',
                    Colors.indigo,
                    Icons.medical_services,
                    () {
                      // Navigate to doctor visit
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, String subtitle, Color color) {
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
  
  Widget _buildQuickLink(
      BuildContext context, String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return Card(
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
