import 'package:auth0_flutter/auth0_flutter.dart'; // Import base package
import 'package:flutter/material.dart';
import 'package:healthsync/src/components/navbar.dart';
import 'package:healthsync/src/pages/homepage.dart';
import 'package:healthsync/src/pages/weekly_summary.dart';
import 'package:healthsync/src/pages/settings_page.dart';
import 'package:healthsync/src/pages/entry_page.dart';
import 'package:healthsync/src/services/auth_service.dart';
import 'package:healthsync/src/services/health_service.dart';
import 'package:healthsync/src/utils/consent_manager.dart';
import 'package:healthsync/src/utils/health_utils.dart';
import 'package:healthsync/src/pages/login_page.dart'; // Import LoginPage
import 'package:healthsync/src/pages/about_page.dart'; // Import AboutPage
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'src/utils/platform.dart';

// Initialize Auth0 for native platforms
// Web initialization will happen within LoginPage
final Auth0 auth0 = Auth0('dev-a01zqddvyzlcd8j4.us.auth0.com', 'aFy0NakvJVNFbWPpPwjkd0QfRmKPPajc');

// Define the Android scheme (only needed for native Android)
const String auth0Scheme = 'com.phenotype.healthsync';

Future<void> main() async { // Make main async
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Get the appropriate platform instance
  final platform = Platform.getInstance();

  // Now you can use platform methods safely
  print('Is mobile: ${platform.isMobile()}');

  // Rest of your app initialization
  runApp(MyApp());
}
// Initialize all services
Future<void> _initializeServices() async {
  // Configure health data access
  await configureHealth();
  
  // Initialize authentication service
  final authService = AuthService();
  await authService.initialize();
  
  // Initialize health service
  final healthService = HealthService();
  await healthService.initialize();
}

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
      home: const NavBarController(email: ''), // Set LoginPage as the initial route
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
  
  // Services
  final AuthService _authService = AuthService();
  final ConsentManager _consentManager = ConsentManager();
  
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

  @override
  void initState() {
    super.initState();
    // Check if health consent is needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHealthConsent();
    });
  }
  
  // Check for health consent
  Future<void> _checkHealthConsent() async {
    await _consentManager.checkAndPromptForConsent(context);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Separate logout function for clarity
  Future<void> _logout() async {
     try {
        await _authService.logout();
        
        // Navigate back to LoginPage after successful logout
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
         // Handle logout errors
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Logout failed: $e')),
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
