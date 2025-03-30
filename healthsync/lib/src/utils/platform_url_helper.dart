import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper class for platform-specific URL operations
class PlatformUrlHelper {
  /// Get the base URL for the current application
  /// On web, returns the configured URL (default: http://localhost:3000)
  /// On mobile, returns null
  static String getBaseUrl() {
    if (kIsWeb) {
      // In a real app, you'd probably want to get this from configuration
      // or detect it dynamically, but for now, we'll use a hardcoded value
      return 'http://localhost:3000';
    }
    return '';
  }
  
  /// Get the origin URL (protocol + domain) for the current application
  static String getOrigin() {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    return '';
  }
}
