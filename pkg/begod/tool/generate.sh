#!/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Generating lexer and parser ==="
cd "$ROOT/grammar"
antlr -Dlanguage=Dart -o "$ROOT/lib/src/generated" -visitor MustacheLexer.g4 MustacheParser.g4

echo "=== Patching ignore_for_file ==="
for f in "$ROOT/lib/src/generated"/*.dart; do
  sed -i '' '2s|// ignore_for_file:.*|// ignore_for_file: unused_field, unused_import, type=lint|' "$f"
done

echo "=== Done ==="

