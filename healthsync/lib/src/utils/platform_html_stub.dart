// This file provides stub implementations for dart:html classes
// This allows the code to compile on non-web platforms

// Stub class for window
class Window {
  Location get location => Location();
  Navigator get navigator => Navigator();
}

// Stub class for location
class Location {
  String? get href => null;
  String? get pathname => null;
}

// Stub class for navigator
class Navigator {
  String get userAgent => '';
}

// Stub instance of window to use in place of the dart:html window
final Window window = Window();
