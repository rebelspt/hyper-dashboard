#!/bin/bash
# Lint script for the project

set -e

echo "=== Running lint checks ==="

# Get dependencies
echo "Getting dependencies..."
dart pub get

# Check formatting
echo "Checking code formatting..."
dart format --output=none --set-exit-if-changed lib/ test/ bin/

# Run static analysis
echo "Running static analysis..."
dart analyze --fatal-infos --fatal-warnings lib/ bin/

echo "=== Lint checks passed ==="
