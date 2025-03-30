import 'platform_interface.dart';

class PlatformStub implements PlatformInterface {
  @override
  String? getCurrentUrl() {
    return null;
  }
  
  @override
  bool isAuth0Ready() {
    return false;
  }
  
  @override
  String getLocationPath() {
    return '';
  }
  
  @override
  String getUserAgent() {
    return '';
  }
  
  @override
  bool isMobile() {
    return true; // Default to mobile for non-web platforms
  }
}

// Implementation for the factory method
PlatformInterface createPlatformImplementation() {
  return PlatformStub();
}
