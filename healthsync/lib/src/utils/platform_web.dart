// platform_web.dart - Web implementation
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'platform_interface.dart';

class PlatformImpl implements PlatformInterface {
  @override
  String getLocationOrigin() {
    return html.window.location.origin;
  }

  @override
  String getLocationPath() {
    return html.window.location.pathname;
  }
  
  @override
  String getFullUrl() {
    return html.window.location.href;
  }
  
  @override
  bool containsParam(String param) {
    return html.window.location.href.contains(param);
  }
}
