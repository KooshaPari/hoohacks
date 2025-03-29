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
        ),
        inputDecorationTheme: InputDecorationTheme( // Consistent input decoration
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        sliderTheme: SliderThemeData( // Style sliders
          activeTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          thumbColor: Theme.of(context).colorScheme.primary,
          overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          valueIndicatorColor: Theme.of(context).colorScheme.primary,
          valueIndicatorTextStyle: const TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // Style buttons
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
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
    _tabController = TabController(length: 4, vsync: this); // Increased length to 4
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
            Tab(text: 'Add Record'), // Added new tab
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DailyLogView(),
          WeeklyNarrativeView(), // Now stateful
          DoctorPrepView(),
          AddRecordView(), // Replaced Placeholder with AddRecordView
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

// Enum for chart types
enum HealthMetric { sleep, steps, calories, hr }

// Updated WeeklyNarrativeView (Stateful)
class WeeklyNarrativeView extends StatefulWidget {
  const WeeklyNarrativeView({super.key});

  @override
  State<WeeklyNarrativeView> createState() => _WeeklyNarrativeViewState();
}

class _WeeklyNarrativeViewState extends State<WeeklyNarrativeView> {
  HealthMetric _selectedMetric = HealthMetric.sleep; // Default selection

  // Helper function to parse numeric data
  double _parseHealthData(String value) {
    final numericString = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  // Helper function to get day initials
  String _getDayInitial(String dateString) {
    return dateString.substring(0, 1); // M, W, F
  }

  // Map metric enum to display string
  String _metricToString(HealthMetric metric) {
    switch (metric) {
      case HealthMetric.sleep: return "Sleep (hrs)";
      case HealthMetric.steps: return "Steps";
      case HealthMetric.calories: return "Active Cal";
      case HealthMetric.hr: return "Resting HR";
    }
  }

  // Map metric enum to data list
  List<double> _getDataForMetric(HealthMetric metric) {
     switch (metric) {
      case HealthMetric.sleep:
        return dummyLogs.map((log) => _parseHealthData(log['healthData']['sleep'])).toList();
      case HealthMetric.steps:
        return dummyLogs.map((log) => _parseHealthData(log['healthData']['steps'])).toList();
      case HealthMetric.calories:
        return dummyLogs.map((log) => _parseHealthData(log['healthData']['activeCalories'])).toList();
      case HealthMetric.hr:
        return dummyLogs.map((log) => _parseHealthData(log['healthData']['restingHR'])).toList();
    }
  }

   // Map metric enum to color
  Color _getColorForMetric(HealthMetric metric) {
     switch (metric) {
      case HealthMetric.sleep: return Colors.indigo;
      case HealthMetric.steps: return Colors.green;
      case HealthMetric.calories: return Colors.orange;
      case HealthMetric.hr: return Colors.red;
    }
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dayInitials = dummyLogs.map((log) => _getDayInitial(log['date'])).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weekly Health Data Trends", style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Dropdown Selector
          DropdownButtonFormField<HealthMetric>(
            value: _selectedMetric,
            decoration: const InputDecoration(
              // labelText: 'Select Metric', // Optional label
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
            items: HealthMetric.values.map((HealthMetric metric) {
              return DropdownMenuItem<HealthMetric>(
                value: metric,
                child: Text(_metricToString(metric)),
              );
            }).toList(),
            onChanged: (HealthMetric? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedMetric = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // Conditionally Displayed Chart
          _WeeklyDataChart(
            title: _metricToString(_selectedMetric),
            data: _getDataForMetric(_selectedMetric),
            dayInitials: dayInitials,
            color: _getColorForMetric(_selectedMetric),
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

// Reusable Bar Chart Widget (_WeeklyDataChart remains largely the same)
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
         // Title is now handled by the dropdown selection, so we might not need it here
         // Text(title, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
         // const SizedBox(height: 8),
         SizedBox(
          height: 150, // Increased height slightly for better visibility
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
                    reservedSize: 35, // Increased reserved size slightly
                    interval: maxY / 4 > 1 ? (maxY / 4).roundToDouble() : 1, // Dynamic interval, at least 1
                     getTitlesWidget: (double value, TitleMeta meta) {
                       // Show 0 and max value, maybe one or two in between
                       if (value == 0 || value == meta.max || value == meta.max / 2) { // Show midpoint too
                         // Avoid showing label if too close to another
                         if (meta.max > 0 && (value - 0).abs() < meta.max * 0.1 && value != 0) return Container();
                         if (meta.max > 0 && (value - meta.max/2).abs() < meta.max * 0.1 && value != meta.max/2) return Container();

                         return SideTitleWidget(
                           meta: meta, // Pass the TitleMeta object
                           space: 4,
                           child: Text(value.toStringAsFixed(0), style: textTheme.bodySmall), // Format simply
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
                  horizontalInterval: maxY / 4 > 1 ? (maxY / 4).roundToDouble() : 1, // Match left title interval
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
              ),
              barGroups: List.generate(data.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data[index],
                      color: color,
                      width: 16, // Bar width
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}


class DoctorPrepView extends StatelessWidget {
  const DoctorPrepView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Doctor Visit Preparation", style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Key Symptoms Reported", style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(doctorSummarySections['Symptoms'] ?? 'No symptom data available.', style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Overall Patterns", style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(doctorSummarySections['Patterns'] ?? 'No pattern data available.', style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Questions for Doctor", style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(doctorSummarySections['Questions'] ?? 'No questions generated.', style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- New Add Record View Widget ---

class AddRecordView extends StatefulWidget {
  const AddRecordView({super.key});

  @override
  State<AddRecordView> createState() => _AddRecordViewState();
}

class _AddRecordViewState extends State<AddRecordView> {
  double _moodValue = 3.0;
  double _energyValue = 3.0;
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Optional: for form validation

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // In a real app, you would save the data here
    // For now, just show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record Saved (Simulated)')),
    );

    // Optionally reset the form
    setState(() {
      _moodValue = 3.0;
      _energyValue = 3.0;
      _symptomsController.clear();
      _notesController.clear();
      _tagsController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form( // Wrap content in a Form
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("New Entry", style: textTheme.headlineSmall),
            Text("How are you feeling today?", style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 24),

            // Mood Slider
            Text("Mood (1-5): ${_moodValue.toInt()}", style: textTheme.titleMedium),
            Slider(
              value: _moodValue,
              min: 1,
              max: 5,
              divisions: 4,
              label: _moodValue.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _moodValue = value;
                });
              },
            ),
            const Row( // Add labels below slider
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("1 (Poor)"), Text("5 (Excellent)")],
            ),
            const SizedBox(height: 24),

            // Energy Slider
            Text("Energy Level (1-5): ${_energyValue.toInt()}", style: textTheme.titleMedium),
            Slider(
              value: _energyValue,
              min: 1,
              max: 5,
              divisions: 4,
              label: _energyValue.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _energyValue = value;
                });
              },
            ),
             const Row( // Add labels below slider
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("1 (Low)"), Text("5 (High)")],
            ),
            const SizedBox(height: 24),

            // Symptoms Text Field
            Text("Symptoms", style: textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _symptomsController,
              decoration: const InputDecoration( // Create a new InputDecoration
                hintText: "Headache:7, Fatigue:5",
                helperText: "Format: Symptom:Severity, e.g., \"Headache:7\"",
                // Inherits border, padding etc. from theme's inputDecorationTheme
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 24),

            // Notes Text Field
            Text("Notes", style: textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration( // Create a new InputDecoration
                hintText: "How was your day? Any notable events or feelings?",
                // Inherits border, padding etc. from theme's inputDecorationTheme
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Tags Text Field
            Text("Tags", style: textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration( // Create a new InputDecoration
                hintText: "stress poor_sleep skipped_meals",
                 helperText: "Space or comma separated, e.g., \"stress poor_sleep\"",
                 // Inherits border, padding etc. from theme's inputDecorationTheme
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 32),

            // Submit Button
            Center( // Center the button
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Save Entry"),
              ),
            ),
            const SizedBox(height: 16), // Add some padding at the bottom
          ],
        ),
      ),
    );
  }
}