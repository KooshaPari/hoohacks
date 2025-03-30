import 'package:auth0_flutter/auth0_flutter.dart'; // Import base package
import 'package:flutter/foundation.dart' show kIsWeb; // To check if running on web
import 'package:flutter/material.dart';
import 'package:healthsync/src/components/graph.dart';
import 'package:healthsync/src/components/data_card.dart';
import 'package:healthsync/src/components/navbar.dart';
import 'package:healthsync/src/pages/homepage.dart';
import 'package:healthsync/src/pages/weekly_summary.dart';
import 'package:healthsync/src/pages/settings_page.dart';
import 'package:healthsync/src/pages/entry_page.dart';
import 'package:healthsync/src/utils/health_utils.dart';
import 'package:healthsync/src/pages/login_page.dart'; // Import LoginPage
import 'package:healthsync/src/pages/about_page.dart'; // Import AboutPage

// Initialize Auth0 for native platforms
// Web initialization will happen within LoginPage
final Auth0 auth0 = Auth0('dev-a01zqddvyzlcd8j4.us.auth0.com', 'aFy0NakvJVNFbWPpPwjkd0QfRmKPPajc');

// Define the Android scheme (only needed for native Android)
const String auth0Scheme = 'com.example.healthsync';


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
  final String email; // Add email parameter

  const NavBarController({super.key, required this.email}); // Make email required

  @override
  _NavBarControllerState createState() => _NavBarControllerState();
}

class _NavBarControllerState extends State<NavBarController> {
  int _selectedIndex = 0;
  // Access email via widget.email

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

  // Separate logout function for clarity
  Future<void> _logout() async {
     try {
        if (kIsWeb) {
          // Web logout must be handled where Auth0Web is initialized (e.g., LoginPage)
          // We might need a way to call that logout from here, or just navigate.
          print("Web logout initiated from NavBar - navigating back to login.");
        } else {
          // Native logout
          await auth0.webAuthentication(scheme: auth0Scheme).logout();
        }

        // Navigate back to LoginPage after successful logout (common logic)
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } on WebAuthenticationException catch (e) {
         // Handle logout errors (native specific)
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Logout failed: ${e.message}')),
           );
         }
      } catch (e) {
         // Handle other potential errors
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('An unexpected error occurred during logout: $e')),
           );
         }
      }
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
            onSelected: (String result) { // No longer async here
              switch (result) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(email: widget.email), // Pass email
                    ),
                  );
                  break;
                case 'about':
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(), // Navigate to AboutPage
                    ),
                  );
                  break;
                case 'logout':
                   _logout(); // Call the separate async logout function
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Text('About'),
              ),
              const PopupMenuDivider(), // Optional separator
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
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
