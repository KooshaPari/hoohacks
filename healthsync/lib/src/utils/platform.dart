import 'platform_interface.dart';
// Use conditional imports to load the right implementation
import 'platform_stub.dart' if (dart.library.html) 'platform_web.dart';

class Platform {
  static PlatformInterface getInstance() {
    return createPlatformImplementation();
  }
}

// The createPlatformImplementation function is imported from either
// platform_stub.dart or platform_web.dart depending on the platform
