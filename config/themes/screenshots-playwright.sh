#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/cli/darwin_arm64/bundle/dashboard"
SHOTS="$ROOT/docs/screenshots/themes"
PORT=8090

mkdir -p "$SHOTS"

for config in "$ROOT/config/themes"/*.yaml; do
  name="$(basename "$config" .yaml)"
  out="$SHOTS/$name.png"
  
  echo "=== Theme: $name ==="
  
  # Start dashboard in background
  "$BUILD" --config "$config" --port "$PORT" --host localhost &
  PID=$!
  
  # Wait for server to be ready
  sleep 3
  
  # Take screenshot with playwright
  playwright screenshot --wait-for-timeout 3000 "http://localhost:$PORT" "$out"
  
  echo "  → Saved to $out"
  
  # Stop dashboard
  kill $PID 2>/dev/null || true
  wait $PID 2>/dev/null || true
  sleep 1
done

echo "=== Done! Screenshots in $SHOTS ==="
ls -la "$SHOTS/"
