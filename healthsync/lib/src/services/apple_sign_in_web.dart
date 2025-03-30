import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppleSignInWeb {
  static Future<UserCredential?> signInWithApple() async {
    // Create and configure Apple sign in button
    final appleSignInButton = html.ButtonElement()
      ..id = 'apple-sign-in-button'
      ..className = 'apple-auth-button'
      ..style.display = 'none'
      ..text = 'Sign in with Apple';

    // Add button to document (invisibly)
    html.document.body?.append(appleSignInButton);

    // Create a completer to resolve the sign-in result
    final completer = Completer<UserCredential?>();

    try {
      // Initialize FirebaseAuth instance
      final auth = FirebaseAuth.instance;
      
      // Create Apple provider
      final provider = OAuthProvider('apple.com');
      provider.addScope('email');
      provider.addScope('name');

      // Trigger sign in flow
      try {
        final result = await auth.signInWithPopup(provider);
        completer.complete(result);
      } catch (e) {
        print('Error during Apple Sign-In popup: $e');
        try {
          // Fallback to redirect method if popup fails
          await auth.signInWithRedirect(provider);
          // Note: this won't actually return a credential 
          // The app needs to handle redirect result on startup
          completer.complete(null);
        } catch (redirectError) {
          print('Error during Apple Sign-In redirect: $redirectError');
          completer.completeError(redirectError);
        }
      }
    } catch (e) {
      print('Error setting up Apple Sign-In: $e');
      completer.completeError(e);
    } finally {
      // Clean up the button
      appleSignInButton.remove();
    }

    return completer.future;
  }

  // Method to handle redirect results - call this at app startup
  static Future<UserCredential?> getRedirectResult() async {
    try {
      final auth = FirebaseAuth.instance;
      return await auth.getRedirectResult();
    } catch (e) {
      print('Error getting redirect result: $e');
      return null;
    }
  }
}
