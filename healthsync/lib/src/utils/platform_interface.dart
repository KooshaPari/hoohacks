abstract class PlatformInterface {
  String? getCurrentUrl();
  bool isAuth0Ready();
  String getLocationPath();
  String getUserAgent();
  bool isMobile();
}