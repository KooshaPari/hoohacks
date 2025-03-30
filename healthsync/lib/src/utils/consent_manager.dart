import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:healthsync/src/services/auth_service.dart';
import 'package:healthsync/src/services/health_service.dart';

class ConsentManager {
  static final ConsentManager _instance = ConsentManager._internal();
  factory ConsentManager() => _instance;

  // Services
  final AuthService _authService = AuthService();
  final HealthService _healthService = HealthService();
  
  // Flag to avoid showing multiple consent prompts
  bool _hasShownPrompt = false;

  ConsentManager._internal();

  // Check if health consent is needed and prompt if necessary
  Future<void> checkAndPromptForConsent(BuildContext context) async {
    // Skip on web, health data APIs aren't available
    if (kIsWeb) return;
    
    // Skip if user is not authenticated
    if (!_authService.isAuthenticated) return;
    
    // Skip if we've already shown a prompt in this session
    if (_hasShownPrompt) return;
    
    // Skip if user already has health permissions
    if (_healthService.isAuthorized) return;
    
    // Check platform and show appropriate prompt
    if (Platform.isIOS && !(_authService.currentUser?.hasHealthkitConsent ?? false)) {
      await _showIOSConsentPrompt(context);
    } else if (Platform.isAndroid && !(_authService.currentUser?.hasGoogleFitConsent ?? false)) {
      await _showAndroidConsentPrompt(context);
    }
    
    // Mark that we've shown a prompt
    _hasShownPrompt = true;
  }
  
  // iOS-style consent prompt
  Future<void> _showIOSConsentPrompt(BuildContext context) async {
    if (!context.mounted) return;
    
    final result = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Health Data Access'),
        content: const Text(
          'HealthSync would like to access your Apple Health data to provide personalized insights and track your health over time. '
          'This includes steps, heart rate, sleep, and other health metrics.\n\n'
          'Your data remains on your device and is never shared without your permission.'
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            isDestructiveAction: true,
            child: const Text('Not Now'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      // User agreed to consent prompt, now request actual permissions
      await _healthService.requestHealthPermissions();
    }
  }
  
  // Android-style consent prompt
  Future<void> _showAndroidConsentPrompt(BuildContext context) async {
    if (!context.mounted) return;
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Health Data Access'),
        content: const Text(
          'HealthSync would like to access your Health Connect data to provide personalized insights and track your health over time. '
          'This includes steps, heart rate, sleep, and other health metrics.\n\n'
          'Your data remains private and is never shared without your permission.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      // User agreed to consent prompt, now request actual permissions
      await _healthService.requestHealthPermissions();
    }
  }
  
  // Reset the shown prompt flag (useful if we want to show prompt again)
  void reset() {
    _hasShownPrompt = false;
  }
}
