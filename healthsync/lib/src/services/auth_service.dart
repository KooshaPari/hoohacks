import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // Use alias to avoid conflict with our User model
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:healthsync/src/models/user_model.dart'
    as AppUser; // Use alias for our User model
import 'package:healthsync/src/services/user_service.dart';
import 'package:healthsync/firebase_options.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '94952939819-26an9b70qdga02rha7d3tsf9mavv35tr.apps.googleusercontent.com'
        : null,
    scopes: ['email', 'profile'],
  );
  final UserService _userService = UserService();

  // Stream for authentication state changes
  Stream<AppUser.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap(_mapFirebaseUserToAppUser);

  // Current user state
  AppUser.User? _currentUser;
  AppUser.User? get currentUser => _currentUser;

  bool get isAuthenticated =>
      _firebaseAuth.currentUser != null && _currentUser != null;

  AuthService._internal();

  // Initialize Firebase (call this from main.dart)
  static Future<void> initializeFirebase() async {
    print('Initializing Firebase...');
    try {
      // Check if Firebase is already initialized to prevent duplicate app error
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('Firebase initialized successfully.');
      } else {
        print('Firebase already initialized, using existing app.');
        // Get the existing app instance
        Firebase.app();
      }
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Handle initialization error appropriately
      rethrow;
    }
  }

  // Map Firebase User to our AppUser model
  Future<AppUser.User?> _mapFirebaseUserToAppUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      return null;
    }

    try {
      // Try to get user from our DB
      AppUser.User? appUser =
          await _userService.getUserByFirebaseUid(firebaseUser.uid);

      if (appUser == null) {
        // If user doesn't exist in our DB, create them
        print('User not found in DB, creating new user entry...');
        final newUser = AppUser.User(
          id: '', // DB will assign ID
          firebaseUid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName,
          authProvider: firebaseUser.providerData.isNotEmpty
              ? firebaseUser.providerData[0].providerId
              : 'firebase',
          authProviderData: {
            // Store basic Firebase user info
            'uid': firebaseUser.uid,
            'email': firebaseUser.email,
            'displayName': firebaseUser.displayName,
            'photoURL': firebaseUser.photoURL,
          },
          hasHealthkitConsent: false, // Default values
          hasGoogleFitConsent: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        appUser = await _userService.createUser(newUser);
        print('New user created in DB: ${appUser?.email}');
      } else {
        // Optionally update user data from Firebase if needed
        // Example: Check if name or photoURL changed
        bool needsUpdate = false;
        Map<String, dynamic> updates = {};
        if (appUser.name != firebaseUser.displayName) {
          updates['name'] = firebaseUser.displayName;
          needsUpdate = true;
        }
        // Add more checks if necessary

        if (needsUpdate) {
          print('Updating existing user data from Firebase...');
          appUser = await _userService.updateUser(
              appUser.id,
              appUser.copyWith(
                name: firebaseUser.displayName, // Example update
                updatedAt: DateTime.now(),
              ));
          print('User data updated.');
        }
      }

      _currentUser = appUser;
      return _currentUser;
    } catch (e) {
      print('Error mapping Firebase user to AppUser: $e');
      _currentUser = null; // Ensure state is cleared on error
      return null;
    }
  }

  // Sign in with Google
  Future<AppUser.User?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In flow...');
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        try {
          // For web, use Firebase's Google auth provider directly
          GoogleAuthProvider googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          
          // Sign in with popup or redirect
          UserCredential userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
          print('Web Google Sign-In successful');
          
          // Map to our user model
          return await _mapFirebaseUserToAppUser(userCredential.user);
        } catch (e) {
          print('Web Google Sign-In failed, falling back to plugin: $e');
          // Try the plugin as fallback
          googleUser = await _googleSignIn.signIn();
        }
      } else {
        // Mobile flow
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        print('Google Sign-In cancelled by user.');
        return null; // User cancelled
      }
      print('Google Sign-In successful, obtaining auth details...');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with Google credential...');
      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      print('Firebase sign-in with Google successful.');

      // Map Firebase user to our app user model (handles DB interaction)
      return await _mapFirebaseUserToAppUser(userCredential.user);
    } catch (e) {
      print('Error during Google Sign-In: $e');
      // Handle specific errors (e.g., platform exceptions) if necessary
      return null;
    }
  }

  // Sign in with Apple
  Future<AppUser.User?> signInWithApple() async {
    // Apple Sign-In is only supported on iOS and macOS
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      print('Apple Sign-In is only available on iOS and macOS.');
      throw UnsupportedError(
          'Apple Sign-In is only available on iOS and macOS.');
    }

    try {
      print('Starting Apple Sign-In flow...');
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
              'com.phenotype.healthsyncservice', // e.g., com.yourcompany.web
          redirectUri: Uri.parse(
            'https://dev-a01zqddvyzlcd8j4.us.auth0.com/.well-known/apple-app-site-association',
          ),
        ),
      );
      print('Apple Sign-In successful, obtaining Firebase credential...');

      // Create an OAuthProvider credential
      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential
            .authorizationCode, // Or accessToken if available/needed
      );

      print('Signing in to Firebase with Apple credential...');
      // Sign in to Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      print('Firebase sign-in with Apple successful.');

      // Map Firebase user to our app user model (handles DB interaction)
      // Note: Apple might only provide name/email on the *first* sign-in.
      // You might need to update the user profile separately if needed.
      return await _mapFirebaseUserToAppUser(userCredential.user);
    } catch (e) {
      print('Error during Apple Sign-In: $e');
      // Handle specific errors (e.g., user cancellation)
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out...');
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      print('Signed out from Firebase.');

      // Sign out from Google (important to allow account switching)
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
          print('Signed out from Google.');
        }
      } catch (e) {
        print('Error signing out from Google: $e');
        // Ignore error, might not have been signed in with Google
      }

      // No explicit sign out needed for Sign in with Apple using this method

      _currentUser = null; // Clear local user state
      print('Sign out complete.');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Update health consent (example of interacting with AppUser)
  Future<AppUser.User?> updateHealthConsent(
      {bool? hasHealthkitConsent, bool? hasGoogleFitConsent}) async {
    if (_currentUser == null) {
      print('Cannot update consent, no user logged in.');
      return null;
    }

    try {
      print('Updating health consent for user: ${_currentUser!.email}');
      _currentUser = await _userService.updateUser(
          _currentUser!.id,
          _currentUser!.copyWith(
            hasHealthkitConsent:
                hasHealthkitConsent ?? _currentUser!.hasHealthkitConsent,
            hasGoogleFitConsent:
                hasGoogleFitConsent ?? _currentUser!.hasGoogleFitConsent,
            updatedAt: DateTime.now(),
          ));
      print('Health consent updated successfully.');
      return _currentUser;
    } catch (e) {
      print('Error updating health consent: $e');
      return null;
    }
  }

  // Get current Firebase user's ID token (useful for backend verification)
  Future<String?> getIdToken() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    try {
      return await firebaseUser.getIdToken();
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }
}
