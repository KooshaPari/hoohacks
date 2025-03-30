import 'package:flutter/material.dart';
import 'package:healthsync/src/components/data_card.dart';
import 'package:healthsync/src/utils/insights_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final InsightsService _insightsService = InsightsService();
  HealthInsight? _insights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final insights = await _insightsService.getHealthInsights();
      setState(() {
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading insights: $e');
      setState(() {
        _insights = HealthInsight.placeholder();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadInsights,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Insights Card
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.insights,
                              size: 40,
                              color: Colors.purple,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Your Health Insights',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else ...[
                          Text(
                            _insights?.summary ?? 'No insights available',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if ((_insights?.recommendations.isNotEmpty ?? false)) ...[
                            const Text(
                              'Recommendations:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._insights!.recommendations.map((recommendation) => 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        recommendation,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'At a Glance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Over the last month, you\'ve averaged:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const DataCard(
                  icon: Icons.directions_run,
                  title: 'Steps',
                  value: 6942,
                  unit: 'steps',
                  color: Colors.green,
                ),
                const DataCard(
                  icon: Icons.favorite,
                  title: 'Heart Rate',
                  value: 72,
                  unit: 'bpm',
                  color: Colors.red,
                ),
                const DataCard(
                  icon: Icons.bedtime,
                  title: 'Sleep',
                  value: 7,
                  unit: 'hours',
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}