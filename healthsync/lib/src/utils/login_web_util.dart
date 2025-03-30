import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

// Moved SignInMethod enum to login_page.dart

class LoginWebUtil {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Handle Apple Sign In for web
  static Future<UserCredential?> signInWithAppleWeb() async {
    if (!kIsWeb) {
      throw UnsupportedError('This method is only for web platform');
    }

    try {
      print('Configuring Apple Provider for web sign-in...');
      // Configure the provider
      final provider = OAuthProvider('apple.com')
        ..addScope('email')
        ..addScope('name');

      // Try to sign in with popup first
      try {
        print('Attempting Apple sign-in with popup...');
        final result = await _auth.signInWithPopup(provider);
        print('Apple popup sign-in successful: ${result.user?.email}');
        return result;
      } catch (e) {
        print('Apple Sign-In popup failed, trying redirect: $e');
        // Check if Firebase is properly initialized
        if (_auth.app == null) {
          print('Firebase Auth not properly initialized. Ensure Firebase is initialized before calling this method.');
          throw Exception('Firebase not initialized');
        }
        // Fallback to redirect (won't return credentials directly)
        print('Falling back to redirect auth flow...');
        await _auth.signInWithRedirect(provider);
        print('Redirect initiated, page will refresh...');
        return null;
      }
    } catch (e) {
      print('Error in Apple Sign-In for web: $e');
      rethrow;
    }
  }

  // Handle Google Sign In for web
  static Future<UserCredential?> signInWithGoogleWeb() async {
    if (!kIsWeb) {
      throw UnsupportedError('This method is only for web platform');
    }

    try {
      print('Configuring Google Provider for web sign-in...');
      // Configure the provider
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      // Try to sign in with popup first
      try {
        print('Attempting Google sign-in with popup...');
        final result = await _auth.signInWithPopup(provider);
        print('Google popup sign-in successful: ${result.user?.email}');
        return result;
      } catch (e) {
        print('Google Sign-In popup failed, trying redirect: $e');
        // Check if Firebase is properly initialized
        if (_auth.app == null) {
          print('Firebase Auth not properly initialized. Ensure Firebase is initialized before calling this method.');
          throw Exception('Firebase not initialized');
        }
        // Fallback to redirect (won't return credentials directly)
        print('Falling back to redirect auth flow...');
        await _auth.signInWithRedirect(provider);
        print('Redirect initiated, page will refresh...');
        return null;
      }
    } catch (e) {
      print('Error in Google Sign-In for web: $e');
      rethrow;
    }
  }

  // Utility function to check for redirect result
  // Call this on app startup to handle sign-in redirects
  static Future<UserCredential?> checkRedirectResult() async {
    if (!kIsWeb) return null;
    
    try {
      print('Checking for redirect sign-in result...');
      // Check if there's a pending redirect result
      final result = await _auth.getRedirectResult();
      
      if (result.user != null) {
        print('User signed in after redirect: ${result.user!.email}');
        print('Auth provider: ${result.credential?.providerId}');
        return result;
      } else {
        print('No pending redirect sign-in result found.');
      }
      return null;
    } catch (e) {
      print('Error checking redirect result: $e');
      if (e.toString().contains('auth/operation-not-supported-in-this-environment')) {
        print('This browser environment does not support this operation.');
      }
      return null;
    }
  }
}
