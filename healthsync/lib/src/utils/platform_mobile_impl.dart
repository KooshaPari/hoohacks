// lib/src/utils/platform_mobile_impl.dart
// This file will only be imported in mobile context
import 'platform_interface.dart';
import 'platform_stub.dart';

// This will override the stub implementation when on mobile
PlatformInterface getPlatformMobile() => PlatformMobile();
