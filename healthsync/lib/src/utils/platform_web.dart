// Use conditional import for web-only libraries
import 'dart:html' if (dart.library.io) './platform_html_stub.dart';
import 'platform_interface.dart';

class PlatformWeb implements PlatformInterface {
  @override
  String? getCurrentUrl() {
    return window.location.href;
  }
  
  @override
  bool isAuth0Ready() {
    // Implement your Auth0 check logic here
    return true; // Replace with actual implementation
  }
  
  @override
  String getLocationPath() {
    // Fix null safety issue by returning empty string when null
    return window.location.pathname ?? '';
  }
  
  @override
  String getUserAgent() {
    return window.navigator.userAgent;
  }
  
  @override
  bool isMobile() {
    // Implement mobile detection logic
    final userAgent = window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') || 
           userAgent.contains('android') || 
           userAgent.contains('iphone');
  }
}

// Implementation for the factory method
PlatformInterface createPlatformImplementation() {
  return PlatformWeb();
}
