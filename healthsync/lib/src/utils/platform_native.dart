// platform_native.dart - Native implementation (iOS, Android)
import 'platform_interface.dart';

class PlatformImpl implements PlatformInterface {
  @override
  String getLocationOrigin() {
    // Default for native platforms
    return 'http://localhost:3000';
  }

  @override
  String getLocationPath() {
    // Default for native platforms
    return '/';
  }
  
  @override
  String getFullUrl() {
    // Default for native platforms
    return 'http://localhost:3000/';
  }
  
  @override
  bool containsParam(String param) {
    return false;
  }
}
