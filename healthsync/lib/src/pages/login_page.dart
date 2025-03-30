// Import necessary packages
import 'package:auth0_flutter/auth0_flutter.dart'; // Import base package for native and Credentials
import 'package:auth0_flutter/auth0_flutter_web.dart'; // Import web version explicitly
import 'package:flutter/foundation.dart' show kIsWeb;
// Web imports - only for web platform
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:healthsync/main.dart' show NavBarController, auth0, auth0Scheme; // Import native instance and scheme from main.dart
import 'package:healthsync/src/models/user_model.dart';
import 'package:healthsync/src/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
} // End of LoginPage class

class _LoginPageState extends State<LoginPage> {
  String? _errorMessage;
  bool _isLoading = false;
  bool _isAuth0Ready = !kIsWeb; // Initialize as true for native, false for web

  // Auth service
  final AuthService _authService = AuthService();
  
  // Initialize Auth0Web specifically for this page if on web
  late final Auth0Web? auth0Web; // Keep this nullable

  @override
  void initState() {
    super.initState();
    
    // Check if running on web platform
    if (kIsWeb) {
      _waitForAuth0();
    } else {
      // Native platform - initialize directly
      _initializeAuth();
    }
  }
  
  // Wait for Auth0 to be ready on web
  Future<void> _waitForAuth0() async {
    setState(() => _isLoading = true);
    
    try {
      // Use a simple delay approach since we're having trouble with JS evaluation
      // Give Auth0 a reasonable time to load (3 seconds)
      print('Waiting for Auth0 SDK to load...');
      await Future.delayed(const Duration(seconds: 3));
      
      // Set auth0 as ready
      if (mounted) {
        setState(() {
          _isAuth0Ready = true;
        });
      }
      
      // Proceed with initialization
      await _initializeAuth();
      
    } catch (e) {
      print('Error waiting for Auth0: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing authentication service. Please try refreshing the page.';
          _isLoading = false;
        });
      }
    }
  }
  
  // Initialize authentication
  Future<void> _initializeAuth() async {
    setState(() => _isLoading = true);
    
    try {
      // Initialize AuthService
      await _authService.initialize();
      
      // Check if already authenticated
      if (_authService.isAuthenticated && _authService.currentUser != null) {
        // User is already authenticated, navigate to main screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavBarController(
                email: _authService.currentUser!.email,
              ),
            ),
          );
        }
        return;
      }
      
      // Initialize Auth0Web for web platform
      if (kIsWeb) {
        auth0Web = Auth0Web('dev-a01zqddvyzlcd8j4.us.auth0.com', 'aFy0NakvJVNFbWPpPwjkd0QfRmKPPajc');
        // Handle the redirect callback on page load for web
        await _handleWebRedirect();
      } else {
        auth0Web = null; // Not needed for native
      }
    } catch (e) {
      print('Error initializing auth: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred during initialization.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAuth0Ready = true;
        });
      }
    }
  }

  // Handles the redirect from Auth0 on web
  Future<void> _handleWebRedirect() async {
    // Ensure this only runs on web and the web client is potentially available
    if (!kIsWeb || auth0Web == null) return;

    try {
      print('Attempting to handle Auth0 redirect callback in LoginPage...');
      
      // Wait a short time to ensure Auth0 initialization is complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Use the web instance to handle the callback
      print('Calling auth0Web.onLoad() to process the callback');
      final credentials = await auth0Web!.onLoad();
      
      print('Auth0Web onLoad completed: ${credentials != null ? 'With credentials' : 'No credentials'}');
      
      // Check if credentials are not null before processing
      if (credentials != null) {
        print('Successfully obtained Auth0 credentials, processing authentication');
        await _processAuthentication(credentials);
      } else {
        // Handle case where onLoad returns null
        print('onLoad returned null credentials.');
        
        // This is likely just the initial page load or a failed callback
        setState(() => _isLoading = false);
      }
    } on WebAuthenticationException catch (e) {
       print('WebAuthenticationException during onLoad: ${e.message}');
       if (mounted) {
         setState(() {
           _errorMessage = 'Login callback error: ${e.message}';
           _isLoading = false;
         });
       }
    } catch (e) {
       print('Unexpected error during onLoad: $e');
       if (mounted) {
         setState(() {
           _errorMessage = 'An unexpected error occurred during login callback: $e';
           _isLoading = false;
         });
       }
    }
  }

  // Processes credentials after successful login (web or native)
  Future<void> _processAuthentication(Credentials credentials) async {
    if (!mounted) return; // Check if the widget is still in the tree

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear errors on success
    });
    
    try {
      print('Processing authentication for user: ${credentials.user.email}');
      
      // Process authentication through our auth service
      final User? user = await _authService.processAuthentication(credentials);
      
      if (user != null) {
        // Successful authentication with backend
        print('Successfully authenticated user: ${user.email}');
        
        // Navigation to main screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavBarController(email: user.email)),
          );
        }
      } else {
        // Authentication with backend failed but we have Auth0 credentials
        // Create fallback user to allow the app to function
        print('Backend user processing failed - using fallback authentication');
        
        // Extract email from Auth0 credentials
        final String? userEmail = credentials.user.email;
        
        if (userEmail != null && userEmail.isNotEmpty) {
          print('Using email from Auth0 credentials: $userEmail');
          
          if (mounted) {
            // Navigate using just the email from Auth0
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavBarController(email: userEmail)),
            );
          }
        } else {
          // Handle case where user processing failed and no email is available
          if (mounted) {
            setState(() {
              _errorMessage = 'Failed to process user authentication. No email available.';
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error processing authentication: $e');
      
      // Attempt fallback with Auth0 credentials
      final String? userEmail = credentials.user.email;
      
      if (userEmail != null && userEmail.isNotEmpty && mounted) {
        print('Error occurred but proceeding with Auth0 credentials: $userEmail');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavBarController(email: userEmail)),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred while processing authentication: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Handles the login button press
  Future<void> _loginWithSSO(String connection) async {
    // Ensure client is ready before attempting login, especially on web
    if (kIsWeb && !_isAuth0Ready) {
       print("Auth0 client not ready yet.");
       if (mounted) {
         setState(() {
           _errorMessage = "Authentication service is initializing, please wait...";
         });
       }
       return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      print('Starting ${kIsWeb ? "web" : "native"} login flow with connection: $connection');
      
      if (kIsWeb && auth0Web != null) {
        // === Web Login ===
        // Use current window location for redirect URL (hardcoded for now)
        const String redirectUrl = 'http://localhost:3000';
        print('Using redirect URL: $redirectUrl');
        
        // Log Auth0 configuration for debugging
        print('Auth0 domain: dev-a01zqddvyzlcd8j4.us.auth0.com');
        print('Auth0 client ID: aFy0NakvJVNFbWPpPwjkd0QfRmKPPajc');
        
        await auth0Web!.loginWithRedirect(
          redirectUrl: redirectUrl,
          parameters: {
            'connection': connection,
            'prompt': 'login', // Force login screen even if already authenticated
            'response_type': 'code', // Use authorization code flow
            'scope': 'openid profile email offline_access', // Request standard scopes
          }
        );
        // Navigation for web happens in _handleWebRedirect after page reloads
      } else if (!kIsWeb) {
        // === Native Login ===
        // Use the 'auth0' instance imported from main.dart
        final credentials = await auth0
            .webAuthentication(scheme: auth0Scheme)
            .login(
              parameters: {
                'connection': connection,
                'scope': 'openid profile email offline_access', // Request standard scopes
              },
              // On iOS 17.4+ / macOS 14.4+ use HTTPS (recommended by Auth0)
              useHTTPS: true, // This is ignored on Android
            );
        
        print('Native login successful, processing credentials');
        await _processAuthentication(credentials); // Process credentials directly for native
      }
    } on WebAuthenticationException catch (e) {
      // Handle login errors (e.g., user cancellation)
      print('WebAuthenticationException during login: ${e.message}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login failed: ${e.message}';
        });
      }
    } catch (e) {
       // Handle other potential errors
       print('Unexpected error during login: $e');
       if (mounted) {
         setState(() {
           _isLoading = false;
           _errorMessage = 'An unexpected error occurred: $e';
         });
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green, // Consistent AppBar color
         titleTextStyle: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center( // Center the content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Debug info in development mode
              if (kIsWeb)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Running on localhost:3000',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
                    const SizedBox(height: 16),
                    Text(
                      _isAuth0Ready ? 'Processing authentication...' : 'Initializing authentication service...',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                )
              else ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login), // Example icon
                  label: const Text('Login with Google'),
                  // Disable button until Auth0 is ready
                  onPressed: !_isAuth0Ready ? null : () => _loginWithSSO('google-oauth2'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Make button wider
                    // Optionally add visual indication for disabled state
                    disabledForegroundColor: Colors.grey.withOpacity(0.38),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                   icon: const Icon(Icons.apple), // Example icon
                   label: const Text('Login with Apple'),
                   // Disable button until Auth0 is ready
                   onPressed: !_isAuth0Ready ? null : () => _loginWithSSO('apple'),
                   style: ElevatedButton.styleFrom(
                     minimumSize: const Size(double.infinity, 50), // Make button wider
                     // Optionally add visual indication for disabled state
                     disabledForegroundColor: Colors.grey.withOpacity(0.38),
                     disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                   ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
