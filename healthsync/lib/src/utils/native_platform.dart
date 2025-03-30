// Implementation for native platforms (iOS, Android, etc.)
import 'platform_interface.dart';

class NativePlatform implements PlatformInterface {
  @override
  String getCurrentUrl() {
    // Native platforms don't use URLs for Auth0 redirects
    // Instead, they use custom URL schemes or App/Universal Links
    return '';
  }
  
  @override
  Future<bool> isAuth0Ready() async {
    // Native platforms always use the Auth0 SDK directly
    // which is loaded with the app startup
    return true;
  }
}
