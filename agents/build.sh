#!/bin/bash
# Build script for the project

set -e

echo "=== Building project ==="

# Get dependencies
echo "Getting dependencies..."
dart pub get

# Build the executable
echo "Building executable..."
dart compile exe bin/dashboard.dart -o build/dashboard

echo "=== Build completed successfully ==="
