import 'package:flutter/material.dart';
import 'package:healthsync/src/models/user_model.dart' as AppUser; // Import with alias
import 'package:healthsync/src/components/navbar.dart';
import 'package:healthsync/src/pages/homepage.dart';
import 'package:healthsync/src/pages/weekly_summary.dart';
import 'package:healthsync/src/pages/settings_page.dart';
import 'package:healthsync/src/pages/entry_page.dart';
import 'package:healthsync/src/services/auth_service.dart';
// Keep this if HealthService is still used
import 'package:healthsync/src/utils/consent_manager.dart';
// Keep this if HealthUtils is still used
import 'package:healthsync/src/pages/login_page.dart'; // Import LoginPage
// Import BasicLoginPage (maybe remove later)
import 'package:healthsync/src/pages/about_page.dart'; // Import AboutPage
// Keep this if Platform is still used

Future<void> main() async {
  // Ensure bindings are initialized before calling Firebase.initializeApp()
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Enable debug print
  debugPrint('App starting...');

  try {
    // Initialize Firebase first
    await AuthService.initializeFirebase(); 
    debugPrint('Firebase initialized.');

    // Get the appropriate platform instance (optional, if needed before MyApp)
    // final platform = Platform.getInstance(); 
    // debugPrint('Is mobile: ${platform.isMobile()}');

    // TODO: Initialize other services like HealthService if needed after Firebase init
    // await configureHealth(); // Example - ensure this is defined or removed
    // final healthService = HealthService();
    // await healthService.initialize(); // Example - ensure this is defined or removed

    // Launch the app
    runApp(const MyApp());
    debugPrint('MyApp launched successfully.');

  } catch (e, stackTrace) {
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Optionally, run a fallback error app here
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Error initializing app: $e')))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a StreamBuilder to listen to auth state changes
    return StreamBuilder<AppUser.User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HealthSync',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: SafeArea(
            child: Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while checking auth state
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  // Handle auth stream errors
                  return Scaffold(
                    body: Center(child: Text('Auth Error: ${snapshot.error}')),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  // User is logged in, navigate to NavBarController
                  // Ensure snapshot.data!.email is not null or handle appropriately
                  return NavBarController(email: snapshot.data!.email ?? 'No Email'); 
                } else {
                  // User is not logged in, show LoginPage
                  return const LoginPage(); 
                }
              },
            ),
          ),
        );
      },
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
  
  // TODO: Ensure HomePage, WeeklySummary, EntryPage are compatible with potential null user initially
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
    // Check if health consent is needed after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only check consent if user is actually logged in (handled by MyApp StreamBuilder now)
       _checkHealthConsent();
    });
  }
  
  // Check for health consent
  Future<void> _checkHealthConsent() async {
    // Ensure user is logged in before checking consent
    if (_authService.currentUser != null) {
       await _consentManager.checkAndPromptForConsent(context);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Separate logout function for clarity
  Future<void> _logout() async {
     try {
        await _authService.signOut(); // Use Firebase signOut
        
        // Navigation back to LoginPage is handled automatically by StreamBuilder in MyApp
        // No explicit navigation needed here anymore if MyApp rebuilds correctly on auth state change.
        // If navigation is still needed (e.g., clearing specific state), do it here.
        print("Logout successful, auth state change should trigger UI update.");

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
            onSelected: (String result) { 
              switch (result) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Pass email if needed, ensure it's available
                      builder: (context) => SettingsPage(email: widget.email), 
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
