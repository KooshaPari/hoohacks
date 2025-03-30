/// Stub implementation of Web APIs for non-web platforms
library;

// Stub for Window class
class Window {
  Window._();
  
  // Define minimal location interface
  final Location location = Location._();
  
  // Singleton instance
  static final Window _instance = Window._();
  static Window get instance => _instance;
}

// Stub for Location
class Location {
  Location._();
  
  String get host => '';
  String get href => '';
  String get origin => '';
  String get pathname => '';
}

// Global window accessor
final Window window = Window.instance;