#!/bin/bash
# Cleanup script for healthsync Flutter project

echo "Cleaning up healthsync Flutter project..."

# Stop any running Flutter processes
echo "Stopping any running Flutter processes..."
pkill -f "flutter" || true

# Clean the Flutter project
echo "Running flutter clean..."
flutter clean

# Delete the Pub cache for web package
echo "Removing web package from Pub cache..."
rm -rf ~/.pub-cache/hosted/pub.dev/web-1.1.1 || true

# Get dependencies after cleaning
echo "Running flutter pub get..."
flutter pub get

# Check if dependencies were properly obtained
echo "Checking dependencies..."
flutter pub deps

echo "Cleanup completed. Try building for iOS again with: flutter build ios"
