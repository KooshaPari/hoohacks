// platform_helper.dart - Entry point for platform-specific code
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_interface.dart';

// Use conditional imports based on platform
import 'platform_native.dart' if (dart.library.html) 'platform_web.dart';

class PlatformHelper {
  static final PlatformInterface _platform = PlatformImpl();
  
  static String getRedirectUrl() {
    if (kIsWeb) {
      return '${_platform.getLocationOrigin()}${_platform.getLocationPath()}';
    } else {
      return 'http://localhost:3000';
    }
  }
  
  static String getOrigin() {
    return _platform.getLocationOrigin();
  }
  
  static String getFullUrl() {
    return _platform.getFullUrl();
  }
  
  static bool urlContainsParam(String param) {
    return _platform.containsParam(param);
  }
}
