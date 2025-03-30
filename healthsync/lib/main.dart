import 'package:flutter/material.dart';
import 'package:healthsync/src/components/graph.dart';
import 'package:healthsync/src/components/data_card.dart';
import 'package:healthsync/src/components/navbar.dart';
import 'package:healthsync/src/pages/homepage.dart';
import 'package:healthsync/src/pages/weekly_summary.dart';
import 'package:healthsync/src/pages/settings_page.dart';
import 'package:healthsync/src/pages/entry_page.dart';
import 'package:healthsync/src/utils/health_utils.dart';
import 'package:healthsync/src/pages/login_page.dart';
import 'package:realm/realm.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureHealth();
  runApp(const MyApp());
}

/*
Probably will have user data look something like this:

final Map<String, dynamic> userData = {
  'mood': 3,
  'energyLevel': 3,
  'steps': 0,
  'calories': 0,
  'heartRate': 0,
  'sleep': 0,
  'symptoms': [],
  'notes': '',
  'tags': [],
};
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(), // Set LoginPage as the initial route
    );
  }
}

class NavBarController extends StatefulWidget {
  const NavBarController({super.key});

  @override
  _NavBarControllerState createState() => _NavBarControllerState();
}

class _NavBarControllerState extends State<NavBarController> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(title: 'HealthSync'),
    const WeeklySummary(),
    const EntryPage(),
  ];

  final List<String> _titles = [
    'HealthSync',
    'Weekly Summary',
    'Entries',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Center(
          child: Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            // open the menu
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onSelected: (String result) {
              switch (result) {
                case 'logout':
                  // Navigate back to LoginPage and remove all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                  break;
                // Add other settings options here if needed in the future
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
              // Add other PopupMenuItems for more settings options
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Middle page changes dynamically
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

