.PHONY: all test deps build clean lint fmt fix run run-local download-assets

all: lint test build

# ── Dependencies ───────────────────────────────────────────────────────────────

deps:
	dart pub get
	cd pkg/begod && dart pub get
	cd pkg/dartkup && dart pub get

# ── Tests ─────────────────────────────────────────────────────────────────────

test: deps test-dashboard test-begod test-dartkup

test-dashboard:
	@echo "=== Dashboard tests ==="
	dart test

test-begod:
	@echo "=== Begod tests ==="
	cd pkg/begod && dart test

test-dartkup:
	@echo "=== Dartkup tests ==="
	cd pkg/dartkup && dart test

# ── Integration tests ─────────────────────────────────────────────────────────

test-integration:
	@echo "=== Dashboard integration tests ==="
	dart test test/widgets/

# ── Build ──────────────────────────────────────────────────────────────────────

build: deps
	@echo "=== Building dashboard ==="
	mkdir -p build/cli/$$(uname -s | tr '[:upper:]' '[:lower:]')_$$(uname -m)/bundle
	dart compile exe bin/hyper_dashboard.dart -o build/cli/$$(uname -s | tr '[:upper:]' '[:lower:]')_$$(uname -m)/bundle/hyper-dashboard

# ── Run ──────────────────────────────────────────────────────────────────────

run:
	dart run bin/hyper_dashboard.dart --config config/demo.yaml

run-local: download-assets
	dart run bin/hyper_dashboard.dart --config config/demo.yaml --local-assets

# ── Assets ────────────────────────────────────────────────────────────────────

download-assets:
	@echo "=== Downloading htmx + alpinejs ==="
	curl -sLo assets/htmx.min.js https://unpkg.com/htmx.org@2.0.10/dist/htmx.min.js
	curl -sLo assets/alpine.min.js https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js

# ── Lint & Format ──────────────────────────────────────────────────────────────

lint:
	dart analyze lib/ bin/ test/

lint-strict:
	dart analyze --fatal-infos --fatal-warnings lib/ bin/ test/

fmt:
	dart format lib/ test/ bin/ pkg/

fmt-check:
	dart format --output=none --set-exit-if-changed lib/ test/ bin/ pkg/

fix:
	dart fix --apply lib/
	dart fix --apply bin/
	dart fix --apply test/

# ── Clean ──────────────────────────────────────────────────────────────────────

clean:
	rm -rf build/cli/ .dart_tool/
	cd pkg/begod && rm -rf .dart_tool/
	cd pkg/dartkup && rm -rf .dart_tool/

# ── Watch ──────────────────────────────────────────────────────────────────────

watch-test:
	dart test --watch

# ── Help ───────────────────────────────────────────────────────────────────────

help:
	@echo "Targets:"
	@echo "  all              Run format-check, lint, test, and build (default)"
	@echo "  test             Run all tests (dashboard + begod + dartkup)"
	@echo "  test-dashboard   Run dashboard tests only"
	@echo "  test-begod       Run begod tests only"
	@echo "  test-dartkup     Run dartkup tests only"
	@echo "  test-integration Run dashboard integration tests"
	@echo "  build            Compile dashboard binary"
	@echo "  run              Run dashboard with demo config (CDN assets)"
	@echo "  run-local        Run dashboard with local assets"
	@echo "  download-assets  Download htmx + alpinejs to assets/"
	@echo "  deps             Install all dependencies"
	@echo "  lint             Run static analysis"
	@echo "  lint-strict      Strict linting"
	@echo "  fmt              Format all code"
	@echo "  fmt-check        Check formatting"
	@echo "  fix              Auto-apply dart fix suggestions"
	@echo "  clean            Remove build artifacts"
	@echo "  watch-test       Run tests in watch mode"
