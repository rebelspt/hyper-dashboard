#!/bin/bash
# Test script for the project

set -e

echo "=== Installing dependencies ==="
dart pub get
cd pkg/begod && dart pub get && cd ../..
cd pkg/dartkup && dart pub get && cd ../..

echo "=== Running dashboard tests ==="
dart test

echo "=== Running begod tests ==="
cd pkg/begod && dart test && cd ../..

echo "=== Running dartkup tests ==="
cd pkg/dartkup && dart test && cd ../..

echo "=== All tests passed ==="
