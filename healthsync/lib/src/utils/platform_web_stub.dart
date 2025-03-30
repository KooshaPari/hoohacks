// lib/src/utils/platform_web_stub.dart (create this file)
import 'platform_interface.dart';
import 'platform_stub.dart';

// This will be used when not on web platform
PlatformInterface getPlatformWeb() => PlatformMobile();