import 'package:flutter/material.dart';

// --- Dummy Data (Converted from JS) ---

const List<Map<String, dynamic>> dummyLogs = [
  {
    "date": "Monday, May 1",
    "mood": "3/5 (Average)",
    "energy": "2/5 (Low)",
    "symptoms": "Headache (6/10 severity)",
    "notes": "Slept poorly last night. Busy day at work with back-to-back meetings.",
    "tags": ["#stress", "#poor_sleep"],
    "healthData": {
      "sleep": "5.5 hours",
      "steps": "4,200",
      "activeCalories": "180",
      "restingHR": "72 bpm"
    }
  },
  {
    "date": "Wednesday, May 3",
    "mood": "4/5 (Good)",
    "energy": "4/5 (Good)",
    "symptoms": "None",
    "notes": "Productive day. Took a walk during lunch break.",
    "tags": ["#good_day"],
    "healthData": {
      "sleep": "7.2 hours",
      "steps": "9,100",
      "activeCalories": "320",
      "restingHR": "68 bpm"
    }
  },
  {
    "date": "Friday, May 5",
    "mood": "2/5 (Poor)",
    "energy": "2/5 (Low)",
    "symptoms": "Headache (7/10 severity), Fatigue (6/10)",
    "notes": "Skipped breakfast, worked through lunch. Headache started around 2pm.",
    "tags": ["#skipped_meals", "#headache"],
    "healthData": {
      "sleep": "6.1 hours",
      "steps": "3,800",
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
    <p><strong>Your Week in Review (May 1-7)</strong></p>
    <p>This week, you logged headaches on 2 days, typically rating them as moderate to severe (6-7/10). Your energy levels tended to be higher on days when you slept more than 7 hours and took more than 8,000 steps. Notably, both headache days occurred when you had fewer than 6 hours of sleep and lower physical activity. Your heart rate was also slightly elevated on these days compared to your headache-free days.</p>
    <p><strong>Pattern Spotlight: Headaches</strong></p>
    <p>Based on your recent entries, three factors appear to correlate with your headache days:</p>
    <ul>
        <li><strong>Sleep Duration:</strong> You averaged 5.8 hours of sleep on headache days vs. 7.3 hours on headache-free days.</li>
        <li><strong>Meal Patterns:</strong> You tagged "skipped meals" on 100% of headache days vs. 0% of headache-free days.</li>
        <li><strong>Physical Activity:</strong> Your step count averaged 4,000 on headache days vs. 8,500 on headache-free days.</li>
    </ul>
""";
final String dummyNarrative = _stripHtmlTags(dummyNarrativeRaw);


const String dummyDoctorSummaryRaw = """
    <p><strong>Health Summary: April 8 - May 8</strong></p>
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
final String dummyDoctorSummary = _stripHtmlTags(dummyDoctorSummaryRaw);


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
          headlineSmall: TextStyle(color: Color(0xFF0056B3), fontWeight: FontWeight.bold), // Match h2 color + bold
          titleLarge: TextStyle(color: Color(0xFF0056B3), fontWeight: FontWeight.bold), // Match h1 color + bold
          titleMedium: TextStyle(fontWeight: FontWeight.bold), // For card titles
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

class WeeklyNarrativeView extends StatelessWidget {
  const WeeklyNarrativeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        dummyNarrative,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class DoctorPrepView extends StatelessWidget {
  const DoctorPrepView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        dummyDoctorSummary,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}