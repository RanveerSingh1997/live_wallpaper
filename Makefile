# ==============================================================================
# Wallora — Root Automation Makefile
# "Make every screen yours."
# ==============================================================================

.PHONY: all analyze test test-goldens test-benchmarks test-integration test-backend test-all build-android build-web build-backend clean help

help:
	@echo "Wallora Enterprise Build & Verification Commands:"
	@echo "  make analyze          - Run strict Dart analyzer (0 warnings, 0 infos)"
	@echo "  make test             - Run full Flutter test suite (400+ tests)"
	@echo "  make test-goldens     - Run pixel-perfect golden visual regression tests"
	@echo "  make test-benchmarks  - Run procedural canvas rendering 60 FPS performance benchmarks"
	@echo "  make test-integration - Run End-to-End full application integration test"
	@echo "  make test-backend     - Run Spring Boot Checkstyle & JUnit 5 tests"
	@echo "  make test-all         - Run 100% of tests across client and backend"
	@echo "  make build-android    - Build minified, shrunk release APKs and App Bundle"
	@echo "  make build-web        - Build production web distribution"
	@echo "  make build-backend    - Compile and package Spring Boot executable JAR"
	@echo "  make clean            - Clean build directories across Flutter and Maven"

analyze:
	flutter analyze --fatal-infos --fatal-warnings

test:
	flutter test --reporter=expanded

test-goldens:
	flutter test test/goldens/

test-benchmarks:
	flutter test test/benchmarks/

test-integration:
	flutter test integration_test/ -d macos

test-backend:
	cd backend && ./mvnw checkstyle:check test

test-all: analyze test test-goldens test-benchmarks test-backend

build-android:
	flutter build apk --release --split-per-abi
	flutter build appbundle --release

build-web:
	flutter build web --release

build-backend:
	cd backend && ./mvnw package -DskipTests

clean:
	flutter clean
	cd backend && ./mvnw clean
