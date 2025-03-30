import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:healthsync/src/models/user_model.dart';
import 'package:healthsync/src/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  // Constants
  static const String domain = 'dev-a01zqddvyzlcd8j4.us.auth0.com';
  static const String clientId = 'aFy0NakvJVNFbWPpPwjkd0QfRmKPPajc';
  static const String scheme = 'com.phenotype.healthsync';

  // Auth0 instances
  final Auth0 auth0 = Auth0(domain, clientId);
  Auth0Web? auth0Web;

  // Secure storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // User service
  final UserService _userService = UserService();

  // Current user state
  User? _currentUser;
  Credentials? _credentials;

  AuthService._internal() {
    if (kIsWeb) {
      auth0Web = Auth0Web(domain, clientId);
    }
  }

  // Initialize and check existing credentials
  Future<void> initialize() async {
    try {
      // Try to load persisted credentials
      final String? credentialsJson =
          await _storage.read(key: 'auth0_credentials');

      if (credentialsJson != null) {
        // Try to parse stored credentials
        Map<String, dynamic> credentialsMap = jsonDecode(credentialsJson);

        // TODO: Add proper credentials validation and refresh if needed

        // Fetch the user from the database
        await _getUserFromDb(credentialsMap['sub'] ??
            (credentialsMap['user'] != null
                ? credentialsMap['user']['sub']
                : null));
      }
    } catch (e) {
      print('Error initializing AuthService: $e');
      // Clear possibly corrupted credentials and any other stored auth data
      await _storage.deleteAll(); // Clear all secure storage for this app
      _currentUser = null; // Ensure local state is also cleared
      _credentials = null;
      // Avoid calling logout() here as it might trigger web redirects if already in a bad state
    }
  }

  // Login with specified connection (provider)
  Future<User?> login(String connection) async {
    try {
      if (kIsWeb && auth0Web != null) {
        // Web login with redirect flow
        await auth0Web!.loginWithRedirect(
            redirectUrl: 'http://localhost:3000',
            parameters: {'connection': connection});
        // User will be processed after redirect in handleRedirectCallback
        return null;
      } else {
        // Native login
        final credentials = await auth0
            .webAuthentication(scheme: scheme)
            .login(parameters: {'connection': connection});

        return await processAuthentication(credentials);
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Handle redirect callback for web auth
  Future<User?> handleRedirectCallback() async {
    if (!kIsWeb || auth0Web == null) return null;

    try {
      final credentials = await auth0Web!.onLoad();
      if (credentials != null) {
        return await processAuthentication(credentials);
      }
    } catch (e) {
      print('Error handling redirect: $e');
      rethrow;
    }
    return null;
  }

  // Process authentication after successful login - public for login page
  Future<User?> processAuthentication(Credentials credentials) async {
    _credentials = credentials;

    // Save credentials securely
    await _storage.write(
      key: 'auth0_credentials',
      value: jsonEncode({
        'access_token': credentials.accessToken,
        'id_token': credentials.idToken,
        'refresh_token': credentials.refreshToken,
        'expires_at': credentials.expiresAt?.millisecondsSinceEpoch,
        // 'scope': credentials.scope, // Commented out due to potential API change / error
        'sub': credentials.user.sub,
        // Explicitly create the user map, ensuring all values are JSON encodable
        'user': {
          'sub': credentials.user.sub ?? '', // Ensure sub is string or empty
          'name': credentials.user.name ?? '', // Ensure name is string or empty
          'email': credentials.user.email ?? '', // Ensure email is string or empty
          'picture': credentials.user.pictureUrl?.toString() ?? '', // Ensure picture is string or empty
          // Add other known UserProfile fields if needed, ensuring they are encodable
        }
      }),
    );

    // Create or get user in the database
    return await _createOrGetUser(credentials);
  }

  // Create or get user in the database
  Future<User?> _createOrGetUser(Credentials credentials) async {
    final auth0User = credentials.user;
    // Ensure pictureUrl is converted to string here as well
    final providerData = {
      'sub': auth0User.sub ?? '',
      'name': auth0User.name ?? '',
      'email': auth0User.email ?? '',
      'picture': auth0User.pictureUrl?.toString() ?? '', // Convert Uri to String or empty
      // Add other metadata from user object
    };

    // Extract the provider from sub field (e.g., 'google-oauth2|123456')
    String provider = 'unknown';
    if (auth0User.sub.contains('|')) {
      provider = auth0User.sub.split('|')[0];
    }

    // Make sure we have an email
    final userEmail = auth0User.email ?? '';
    if (userEmail.isEmpty) {
      print('Error: No email provided by authentication provider');
      return null;
    }

    try {
      // Try to get existing user first
      final existingUser = await _userService.getUserByEmail(userEmail);

      if (existingUser != null) {
        // Update existing user with new auth provider data
        _currentUser = await _userService.updateUser(
            existingUser.id,
            existingUser.copyWith(
              authProvider: provider,
              authProviderData: providerData,
              updatedAt: DateTime.now(),
            ));
        return _currentUser;
      } else {
        // Create new user
        final newUser = User(
          id: '', // ID will be assigned by database
          email: userEmail,
          name: auth0User.name,
          authProvider: provider,
          authProviderData: providerData,
          hasHealthkitConsent: false,
          hasGoogleFitConsent: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _currentUser = await _userService.createUser(newUser);
        return _currentUser;
      }
    } catch (e, stackTrace) {
      // Add stackTrace parameter
      // Log the specific error and stack trace for better debugging
      print('Error creating/getting user in _createOrGetUser: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Get user from database by ID
  Future<User?> _getUserFromDb(String? auth0UserId) async {
    if (auth0UserId == null) return null;

    try {
      final user = await _userService.getUserByAuth0Id(auth0UserId);
      if (user != null) {
        _currentUser = user;
      }
      return user;
    } catch (e) {
      print('Error getting user from database: $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Clear local state
      _currentUser = null;
      _credentials = null;

      // Clear stored credentials
      await _storage.delete(key: 'auth0_credentials');

      // Call Auth0 logout
      if (kIsWeb && auth0Web != null) {
        await auth0Web!.logout(returnToUrl: 'http://localhost:3000');
      } else {
        await auth0.webAuthentication(scheme: scheme).logout();
      }
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // Update health consent for the current user
  Future<User?> updateHealthConsent(
      {bool? hasHealthkitConsent, bool? hasGoogleFitConsent}) async {
    if (_currentUser == null) return null;

    try {
      _currentUser = await _userService.updateUser(
          _currentUser!.id,
          _currentUser!.copyWith(
            hasHealthkitConsent:
                hasHealthkitConsent ?? _currentUser!.hasHealthkitConsent,
            hasGoogleFitConsent:
                hasGoogleFitConsent ?? _currentUser!.hasGoogleFitConsent,
            updatedAt: DateTime.now(),
          ));
      return _currentUser;
    } catch (e) {
      print('Error updating health consent: $e');
      return null;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _credentials != null && _currentUser != null;

  // Get current user
  User? get currentUser => _currentUser;

  // Get access token
  String? get accessToken => _credentials?.accessToken;
}
