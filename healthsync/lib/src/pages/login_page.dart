// Import necessary packages
import 'package:auth0_flutter/auth0_flutter.dart'; // Import base package for native and Credentials
import 'package:auth0_flutter/auth0_flutter_web.dart'; // Import web version explicitly
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:healthsync/main.dart' show NavBarController, auth0, auth0Scheme; // Import native instance and scheme from main.dart
import 'package:healthsync/src/pages/create_account_page.dart'; // Import CreateAccountPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
} // End of LoginPage class

class _LoginPageState extends State<LoginPage> {
  String? _errorMessage;
  Credentials? _credentials; // Use Credentials from base package
  bool _isAuth0Ready = !kIsWeb; // Initialize as true for native, false for web

  // Initialize Auth0Web specifically for this page if on web
  late final Auth0Web? auth0Web; // Keep this nullable

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Initialize Auth0Web instance for web
      auth0Web = Auth0Web('dev-a01zqddvyzlcd8j4.us.auth0.com', 'aFy0NakvJVNFbWPpPwjkd0QfRmKPPajc');
      // Handle the redirect callback on page load for web
      _handleWebRedirect();
    } else {
      auth0Web = null; // Not needed for native
      // _isAuth0Ready is already true for native
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
        _processCredentials(credentials);
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
    } finally {
      // Ensure the client is marked as ready for web regardless of outcome after attempting onLoad
      if (mounted) {
        setState(() {
          _isAuth0Ready = true;
        });
        print('Auth0Web client marked as ready.');
      }
    }
  }

  // Processes credentials after successful login (web or native)
  void _processCredentials(Credentials credentials) {
     if (!mounted) return; // Check if the widget is still in the tree

     setState(() {
       _credentials = credentials;
       _errorMessage = null; // Clear errors on success
     });
     final userEmail = credentials.user.email;

     if (userEmail != null && userEmail.isNotEmpty) {
       // Navigate to the main app page (NavBarController) and pass email
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => NavBarController(email: userEmail)),
       );
     } else {
       // Handle case where email is not available
       setState(() {
         _errorMessage = 'Could not retrieve user email from SSO provider.';
       });
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
        final Credentials credentials = await auth0
            .webAuthentication(scheme: auth0Scheme)
            .login(parameters: {'connection': connection});
        _processCredentials(credentials); // Process credentials directly for native
      }
    } on WebAuthenticationException catch (e) {
      // Handle login errors (e.g., user cancellation)
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: ${e.message}';
        });
      }
    } catch (e) {
       // Handle other potential errors
       if (mounted) {
         setState(() {
           _errorMessage = 'An unexpected error occurred: $e';
         });
       }
    }
  }

   // This function is no longer needed as the button is removed
   // void _navigateToCreateAccount() {
   //  if (!mounted) return;
   //  Navigator.push(
   //    context,
   //    MaterialPageRoute(builder: (context) => const CreateAccountPage()),
   //  );
   // }

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
              // Create Account button removed as requested
            ],
          ),
        ),
      ),
    );
  }
}
