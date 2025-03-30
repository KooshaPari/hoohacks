import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_interface.dart';

// Conditional imports
import 'native_platform.dart' if (dart.library.html) 'web_platform.dart';

/// Factory to get the appropriate platform implementation
PlatformInterface getPlatform() {
  if (kIsWeb) {
    // This will use the web_platform.dart import on web
    return WebPlatform();
  } else {
    // This will use the native_platform.dart import on native platforms
    return NativePlatform();
  }
}
