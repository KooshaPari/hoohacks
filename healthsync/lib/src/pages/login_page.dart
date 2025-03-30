import 'package:flutter/material.dart';
import 'package:healthsync/src/services/auth_service.dart';
import 'package:healthsync/src/models/user_model.dart' as AppUser; // Import with alias
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform; // Import platform checks
import 'package:healthsync/src/utils/login_web_util.dart'; // Import web utils
import 'package:firebase_auth/firebase_auth.dart';

// Define SignInMethod enum here for use in this file
enum SignInMethod { google, apple }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _errorMessage;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Check for redirect result on web
    if (kIsWeb) {
      _checkRedirectResult();
    }
  }

  Future<void> _checkRedirectResult() async {
    try {
      final credential = await LoginWebUtil.checkRedirectResult();
      if (credential != null) {
        // User signed in after redirect - proceed with the app
        print('User signed in after redirect: ${credential.user?.email}');
      }
    } catch (e) {
      print('Error checking redirect result: $e');
    }
  }

  // Handles the login button press
  // Handles the login button press for mobile platforms
  Future<void> _signIn(Future<AppUser.User?> Function() signInMethod) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      final user = await signInMethod();
      // Navigation is handled by StreamBuilder in main.dart, 
      // but we can stop loading indicator here if login fails within the method.
      if (user == null && mounted) {
         // If signInMethod returns null, it likely means cancellation or an error handled within AuthService
         print('Sign-in process did not complete or failed.');
         setState(() {
           _isLoading = false;
           // Optionally set an error message if needed, though AuthService might handle errors better
           _errorMessage = 'Login failed or was cancelled. Please try again.'; 
         });
      }
    } catch (e) {
      print('Error during sign-in attempt: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      }
    } 
  }

  // Web-specific sign-in handling
  Future<void> _webSignIn(SignInMethod method) async {
    if (!kIsWeb) return;
    
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential? credential;
      if (method == SignInMethod.google) {
        print('Starting web Google Sign-In...');
        credential = await LoginWebUtil.signInWithGoogleWeb();
      } else if (method == SignInMethod.apple) {
        print('Starting web Apple Sign-In...');
        credential = await LoginWebUtil.signInWithAppleWeb();
      }
      
      // If null, it means we're using redirect - just keep loading until page refreshes
      if (credential == null) {
        // Don't change state, as page will refresh
        print('Redirect initiated, page will refresh...');
      }
      
      // Otherwise, credential direct from popup
      else if (credential.user != null) {
        print('Sign-in successful via popup: ${credential.user?.email}');
        // Auth state change will trigger navigation
      }
    } catch (e) {
      print('Error during web sign-in: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sign-in failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show Apple Sign-In on web and Apple devices
    final bool showAppleSignIn = kIsWeb || 
        (defaultTargetPlatform == TargetPlatform.iOS || 
         defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green,
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
                const Column(
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
                    SizedBox(height: 16),
                    Text('Processing...', style: TextStyle(fontSize: 14)),
                  ],
                )
              else ...[
                const SizedBox(height: 24),
                // Google Sign In Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.login), // Replace with Google icon if desired
                  label: const Text('Sign in with Google'),
                  onPressed: kIsWeb 
                    ? () => _webSignIn(SignInMethod.google)
                    : () => _signIn(_authService.signInWithGoogle),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), 
                  ),
                ),
                const SizedBox(height: 16),
                // Apple Sign In Button (Conditional)
                if (showAppleSignIn) 
                  ElevatedButton.icon(
                     icon: const Icon(Icons.apple), 
                     label: const Text('Sign in with Apple'),
                     onPressed: kIsWeb
                       ? () => _webSignIn(SignInMethod.apple)
                       : () => _signIn(_authService.signInWithApple),
                     style: ElevatedButton.styleFrom(
                       minimumSize: const Size(double.infinity, 50),
                       backgroundColor: Colors.black,
                       foregroundColor: Colors.white,
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
