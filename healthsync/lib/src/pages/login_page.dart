// Import necessary packages
import 'package:auth0_flutter/auth0_flutter.dart'; // Import base package for native and Credentials
import 'package:auth0_flutter/auth0_flutter_web.dart'; // Import web version explicitly
import 'package:flutter/foundation.dart' show kIsWeb;
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
    
    // Try to load existing credentials and initialize Auth0
    _initializeAuth();
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
      // Use the web instance to handle the callback
      final credentials = await auth0Web!.onLoad();
      
      // Check if credentials are not null before processing
      if (credentials != null) {
        await _processAuthentication(credentials);
      } else {
        // Handle case where onLoad returns null (e.g., no login attempt was made or callback is invalid)
        print('onLoad returned null credentials.');
      }
    } on WebAuthenticationException catch (e) {
       print('Error during onLoad: ${e.message}');
       if (mounted) {
         setState(() {
           _errorMessage = 'Login callback error: ${e.message}';
         });
       }
    } catch (e) {
       print('Unexpected error during onLoad: $e');
       if (mounted) {
         setState(() {
           _errorMessage = 'An unexpected error occurred during login callback: $e';
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
      // Process authentication through our auth service
      final User? user = await _authService.processAuthentication(credentials);
      
      if (user != null) {
        // Navigation to main screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavBarController(email: user.email)),
          );
        }
      } else {
        // Handle case where user processing failed
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to process user authentication.';
          });
        }
      }
    } catch (e) {
      print('Error processing authentication: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred while processing authentication.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handles the login button press
  Future<void> _loginWithSSO(String connection) async {
    // Ensure client is ready before attempting login, especially on web
    if (!_isAuth0Ready) {
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
      if (kIsWeb && auth0Web != null) {
        // === Web Login ===
        await auth0Web!.loginWithRedirect(
          redirectUrl: 'http://localhost:3000', // Your configured callback URL for web
          parameters: {'connection': connection}
        );
        // Navigation for web happens in _handleWebRedirect after page reloads
      } else if (!kIsWeb) {
        // === Native Login ===
        // Use the 'auth0' instance imported from main.dart
        final credentials = await auth0
            .webAuthentication(scheme: auth0Scheme)
            .login(parameters: {'connection': connection});
        await _processAuthentication(credentials); // Process credentials directly for native
      }
    } on WebAuthenticationException catch (e) {
      // Handle login errors (e.g., user cancellation)
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login failed: ${e.message}';
        });
      }
    } catch (e) {
       // Handle other potential errors
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
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green))
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
