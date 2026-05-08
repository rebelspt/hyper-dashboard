.PHONY: all test deps build clean lint fmt fix

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
	dart compile exe bin/dashboard.dart -o build/cli/$$(uname -s | tr '[:upper:]' '[:lower:]')_$$(uname -m)/bundle/dashboard

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
	@echo "  deps             Install all dependencies"
	@echo "  lint             Run static analysis"
	@echo "  lint-strict      Strict linting"
	@echo "  fmt              Format all code"
	@echo "  fmt-check        Check formatting"
	@echo "  fix              Auto-apply dart fix suggestions"
	@echo "  clean            Remove build artifacts"
	@echo "  watch-test       Run tests in watch mode"
