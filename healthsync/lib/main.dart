import 'package:flutter/material.dart';
import 'package:healthsync/src/components/graph.dart';
import 'package:healthsync/src/components/data_card.dart';
import 'package:healthsync/src/components/navbar.dart';
import 'package:healthsync/src/pages/homepage.dart';
import 'package:healthsync/src/pages/weekly_summary.dart';
import 'package:healthsync/src/pages/settings_page.dart';
import 'package:healthsync/src/pages/entry_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NavBarController(),
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
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              // open settings
            }
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

