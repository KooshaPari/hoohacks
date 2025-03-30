// Abstract interface for platform-specific functionality
abstract class PlatformInterface {
  // Get the current URL for redirection purposes
  String getCurrentUrl();
  
  // Check if the platform is ready for Auth0
  Future<bool> isAuth0Ready();
}
