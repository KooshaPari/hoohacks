// lib/src/utils/platform_web_impl.dart
// This file will only be imported in web context
import 'platform_interface.dart';
import 'platform_web.dart';

// This will override the stub implementation when on web
PlatformInterface getPlatformWeb() => PlatformWeb();
