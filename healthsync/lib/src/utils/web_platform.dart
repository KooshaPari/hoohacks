// Implementation for web platforms using dart:html
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'platform_interface.dart';

class WebPlatform implements PlatformInterface {
  @override
  String getCurrentUrl() {
    return '${html.window.location.origin}${html.window.location.pathname}';
  }
  
  @override
  Future<bool> isAuth0Ready() async {
    try {
      // Check if the auth0Ready global variable is true
      final result = await html.window.eval('window.auth0Ready === true');
      return result == true;
    } catch (e) {
      print('Error checking Auth0 readiness: $e');
      return false;
    }
  }
}
