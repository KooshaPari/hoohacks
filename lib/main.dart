import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'dart:math'; // Import for max function

// --- Dummy Data (Converted from JS) ---

const List<Map<String, dynamic>> dummyLogs = [
  {
    "date": "Monday, March 24, 2025",
    "mood": "3/5 (Average)",
    "energy": "2/5 (Low)",
    "symptoms": "Headache (6/10 severity)",
    "notes": "Slept poorly last night. Busy day at work with back-to-back meetings.",
    "tags": ["#stress", "#poor_sleep"],
    "healthData": {
      "sleep": "5.5 hours",
      "steps": "4200", // Removed comma for easier parsing
      "activeCalories": "180",
      "restingHR": "72 bpm"
    }
  },
  {
    "date": "Wednesday, March 26, 2025",
    "mood": "4/5 (Good)",
    "energy": "4/5 (Good)",
    "symptoms": "None",
    "notes": "Productive day. Took a walk during lunch break.",
    "tags": ["#good_day"],
    "healthData": {
      "sleep": "7.2 hours",
      "steps": "9100", // Removed comma
      "activeCalories": "320",
      "restingHR": "68 bpm"
    }
  },
  {
    "date": "Friday, March 28, 2025",
    "mood": "2/5 (Poor)",
    "energy": "2/5 (Low)",
    "symptoms": "Headache (7/10 severity), Fatigue (6/10)",
    "notes": "Skipped breakfast, worked through lunch. Headache started around 2pm.",
    "tags": ["#skipped_meals", "#headache"],
    "healthData": {
      "sleep": "6.1 hours",
      "steps": "3800", // Removed comma
      "activeCalories": "150",
      "restingHR": "74 bpm"
    }
  }
];

// Basic HTML stripping for narrative/summary for simplicity
String _stripHtmlTags(String htmlString) {
  return htmlString
      .replaceAll(RegExp(r'<[^>]*>'), '\n') // Replace tags with newlines
      .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove multiple consecutive newlines
      .trim();
}


const String dummyNarrativeRaw = """
    <p><strong>Your Week in Review (March 24-28)</strong></p>
    <p>This week, you logged headaches on 2 days, typically rating them as moderate to severe (6-7/10). Your energy levels tended to be higher on days when you slept more than 7 hours and took more than 8,000 steps. Notably, both headache days occurred when you had fewer than 6 hours of sleep and lower physical activity. Your heart rate was also slightly elevated on these days compared to your headache-free days.</p>
    <p><strong>Pattern Spotlight: Headaches</strong></p>
    <p>Based on your recent entries, three factors appear to correlate with your headache days:</p>
    <ul>
        <li><strong>Sleep Duration:</strong> You averaged 5.8 hours of sleep on headache days vs. 7.3 hours on headache-free days.</li>
        <li><strong>Meal Patterns:</strong> You tagged "skipped meals" on 100% of headache days vs. 0% of headache-free days.</li>
        <li><strong>Physical Activity:</strong> Your step count averaged 4,000 on headache days vs. 8,500 on headache-free days.</li>
    </ul>
""";
// Extract only the "Week in Review" part for the card
final String weekInReviewText = _stripHtmlTags(
    dummyNarrativeRaw.substring(
        dummyNarrativeRaw.indexOf("<p><strong>Your Week in Review"),
        dummyNarrativeRaw.indexOf("<p><strong>Pattern Spotlight:")
    )
);
// Keep the full narrative for potential future use or if needed elsewhere
final String fullDummyNarrative = _stripHtmlTags(dummyNarrativeRaw);


const String dummyDoctorSummaryRaw = """
    <p><strong>Health Summary: Feb 28 - March 28</strong></p>
    <p><strong>Key Symptoms Reported:</strong></p>
    <ul>
        <li>Headaches: 8 occurrences (avg. severity 6.5/10)</li>
        <li>Fatigue: 5 occurrences (avg. severity 5/10)</li>
        <li>Digestive Issues: 3 occurrences (avg. severity 4/10)</li>
    </ul>
    <p><strong>Overall Patterns:</strong></p>
    <ul>
        <li>Headaches occurred most frequently on days following less than 6 hours of sleep (75% of instances).</li>
        <li>Headaches were reported on 80% of days with "skipped meals" tag.</li>
        <li>Higher activity levels (>7,000 steps) were associated with fewer symptoms overall.</li>
    </ul>
    <p><strong>Questions for Doctor:</strong></p>
    <ul>
        <li>Could my headaches be related to my sleep patterns?</li>
        <li>Are there specific types of physical activity you'd recommend?</li>
        <li>Should I be concerned about the correlation between meals and headaches?</li>
    </ul>
""";
// Parse the doctor summary into sections
Map<String, String> _parseDoctorSummary(String rawSummary) {
  final summary = _stripHtmlTags(rawSummary);
  final sections = <String, String>{};

  final symptomsMatch = RegExp(r'Key Symptoms Reported:\n(.*?)\nOverall Patterns:', dotAll: true).firstMatch(summary);
  if (symptomsMatch != null) {
    sections['Symptoms'] = symptomsMatch.group(1)!.trim();
  }

  final patternsMatch = RegExp(r'Overall Patterns:\n(.*?)\nQuestions for Doctor:', dotAll: true).firstMatch(summary);
  if (patternsMatch != null) {
    sections['Patterns'] = patternsMatch.group(1)!.trim();
  }

   final questionsMatch = RegExp(r'Questions for Doctor:\n(.*)', dotAll: true).firstMatch(summary);
  if (questionsMatch != null) {
    sections['Questions'] = questionsMatch.group(1)!.trim();
  }

  return sections;
}
final Map<String, String> doctorSummarySections = _parseDoctorSummary(dummyDoctorSummaryRaw);


// --- App Code ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthSync Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F4F4), // Match body background
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0056B3), // Match h1, h2 color
          secondary: Colors.blueAccent, // Placeholder
        ),
        fontFamily: 'sans-serif', // Match body font-family
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF333333), height: 1.6), // Match body color and line-height
          headlineSmall: TextStyle(color: Color(0xFF0056B3), fontWeight: FontWeight.bold, fontSize: 18), // Match h2 color + bold
          titleLarge: TextStyle(color: Color(0xFF0056B3), fontWeight: FontWeight.bold), // Match h1 color + bold
          titleMedium: TextStyle(fontWeight: FontWeight.bold), // For card titles
          bodySmall: TextStyle(color: Colors.grey), // For chart titles/axis
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0056B3), // Use primary color for AppBar
          foregroundColor: Colors.white, // White text on AppBar
        ),
        cardTheme: CardTheme( // Style cards similar to sections
          color: Colors.white,
          elevation: 2.0, // Similar to box-shadow
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjusted margin
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        )
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthSync'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Doctor Visits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DailyLogView(),
          WeeklyNarrativeView(),
          DoctorPrepView(),
        ],
      ),
    );
  }
}

// --- Tab View Widgets ---

class DailyLogView extends StatelessWidget {
  const DailyLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView.builder(
      itemCount: dummyLogs.length,
      itemBuilder: (context, index) {
        final log = dummyLogs[index];
        final healthData = log['healthData'] as Map<String, dynamic>;
        final tags = log['tags'] as List<dynamic>;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log['date'], style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Mood: ${log['mood']}'),
                Text('Energy: ${log['energy']}'),
                Text('Symptoms: ${log['symptoms']}'),
                const SizedBox(height: 4),
                Text('Notes: ${log['notes']}'),
                const SizedBox(height: 4),
                Text('Tags: ${tags.join(', ')}', style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text('Apple Health Data:', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text(
                    'Sleep: ${healthData['sleep']} | Steps: ${healthData['steps']} | Active Calories: ${healthData['activeCalories']} | Resting HR: ${healthData['restingHR']}',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Updated WeeklyNarrativeView with Charts
class WeeklyNarrativeView extends StatelessWidget {
  const WeeklyNarrativeView({super.key});

  // Helper function to parse numeric data
  double _parseHealthData(String value) {
    final numericString = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  // Helper function to get day initials
  String _getDayInitial(String dateString) {
    // Assuming format "Weekday, Month Day, Year"
    return dateString.substring(0, 1); // M, W, F
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Prepare data for charts
    final List<double> sleepData = dummyLogs.map((log) => _parseHealthData(log['healthData']['sleep'])).toList();
    final List<double> stepsData = dummyLogs.map((log) => _parseHealthData(log['healthData']['steps'])).toList();
    final List<double> caloriesData = dummyLogs.map((log) => _parseHealthData(log['healthData']['activeCalories'])).toList();
    final List<double> hrData = dummyLogs.map((log) => _parseHealthData(log['healthData']['restingHR'])).toList();
    final List<String> dayInitials = dummyLogs.map((log) => _getDayInitial(log['date'])).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weekly Health Data Trends", style: textTheme.headlineSmall),
          const SizedBox(height: 20),
          // Charts Section in a Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _WeeklyDataChart(title: "Sleep (hrs)", data: sleepData, dayInitials: dayInitials, color: Colors.indigo)),
              const SizedBox(width: 8),
              Expanded(child: _WeeklyDataChart(title: "Steps", data: stepsData, dayInitials: dayInitials, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 20),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _WeeklyDataChart(title: "Active Cal", data: caloriesData, dayInitials: dayInitials, color: Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _WeeklyDataChart(title: "Resting HR", data: hrData, dayInitials: dayInitials, color: Colors.red)),
            ],
          ),

          const SizedBox(height: 24),
          // Week in Review Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text("Your Week in Review", style: textTheme.titleMedium),
                   const SizedBox(height: 8),
                   Text(
                     weekInReviewText.replaceFirst("Your Week in Review (March 24-28)", "").trim(), // Remove redundant title
                     style: textTheme.bodyMedium,
                   ),
                 ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Bar Chart Widget
class _WeeklyDataChart extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> dayInitials;
  final Color color;

  const _WeeklyDataChart({
    required this.title,
    required this.data,
    required this.dayInitials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final maxY = data.isEmpty ? 10.0 : data.reduce(max) * 1.2; // Add padding to max Y

    return Column(
      children: [
         Text(title, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
         const SizedBox(height: 8),
         SizedBox(
          height: 120, // Fixed height for chart area
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(enabled: false), // Disable touch interactions for simplicity
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < dayInitials.length) {
                        return SideTitleWidget(
                          meta: meta, // Pass the TitleMeta object
                          space: 4,
                          child: Text(dayInitials[index], style: textTheme.bodySmall),
                        );
                      }
                      return Container();
                    },
                    reservedSize: 18,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: maxY / 4, // Adjust interval based on max Y
                     getTitlesWidget: (double value, TitleMeta meta) {
                       // Show 0 and max value, maybe one or two in between
                       if (value == 0 || value == meta.max) {
                         return SideTitleWidget(
                           meta: meta, // Pass the TitleMeta object
                           space: 4,
                           child: Text(meta.formattedValue, style: textTheme.bodySmall),
                         );
                       }
                       return Container(); // Hide intermediate labels for simplicity
                     }
                  ),
                ),
              ),
              borderData: FlBorderData(show: false), // Hide border
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false, // Hide vertical grid lines
                  horizontalInterval: maxY / 4, // Match left title interval
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
              ),
              barGroups: data.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: color,
                      width: 12, // Adjust bar width
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// Updated DoctorPrepView with Cards
class DoctorPrepView extends StatelessWidget {
  const DoctorPrepView({super.key});

  Widget _buildInfoCard(BuildContext context, String title, String content) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(content, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Only vertical padding for scroll view
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch cards horizontally
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding for title
            child: Text(
              "Doctor Visit Preparation", // Overall title for the view
              style: textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(context, "Key Symptoms Reported", doctorSummarySections['Symptoms'] ?? "No data"),
          _buildInfoCard(context, "Overall Patterns", doctorSummarySections['Patterns'] ?? "No data"),
          _buildInfoCard(context, "Questions for Doctor", doctorSummarySections['Questions'] ?? "No data"),
        ],
      ),
    );
  }
}