# Changelog

All notable changes to the Wallora project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-24

### Added
- **Core Architecture & Design System**:
  - Unidirectional Data Flow (UDF) powered by BLoC (`WallpaperIntent` -> `WallpaperBloc` -> `WallpaperState`).
  - Pure domain use cases for wallpaper application, favorites, downloads, and circadian schedules.
  - Complete token harmonization across all screens and widgets using `AppColors` and `AppDimensions` (zero raw hex color literals).
  - Cross-platform `HttpNetworkClient` with interceptor pipeline running seamlessly on Android, iOS, iPadOS, macOS, and Web.
- **Offline Storage & Network Resiliency**:
  - Configurable `LruStorageManager` with a 350MB ceiling, 80% eviction watermark ratio, and pin protection for user downloads.
  - `NetworkConnectivityService` and `ConnectivityRetryQueue` for offline detection and automatic replaying of deferred network actions upon reconnection.
  - `FeedPrefetchManager` for background video pre-caching (<50ms playback start in vertical feed).
- **12 Customization Studios & Personalization Engines**:
  - Quote Studio: kinetic typography and custom affirmations.
  - Wallpaper Effects & Filters: exposure, contrast, blur, and chromatic aberration.
  - Auto-Rotation Hub: timed background wallpaper transitions with Wi-Fi only protection.
  - Lock Screen Dynamics: customized time, date, and typography lock screen overlays.
  - 3D Spatial Parallax: gyroscope and gesture-driven multi-layer depth.
  - Battery & System Telemetry: real-time hardware battery governor, OLED true-black efficiency, and dynamic frame-rate governor (60 FPS / 30 FPS / Adaptive Eco).
  - Aura Chromatic Harmonizer: dynamic fluid neon backlighting.
  - Standby Desk Dock: OLED clock and charging bedside dock.
  - Aurora Wave Synthesizer: procedural canvas wave generation.
  - Atmospheric Weather Studio: dynamic climate and weather particle synthesis.
  - Wallaza Cloud Discovery: REST API cloud wallpaper integration with Spring Boot proxy.
  - Community Exchange: shareable `WalloraScreenBlueprint` setup bundles.
- **Platform Bridges & Native Hardware**:
  - Android native `VideoWallpaperService` with zero sleep overhead (decoders release surface and pause when screen turns off).
  - iPadOS/iOS native Photos integration (`IPadWallpaperDialog`) unlocking native "Use as Wallpaper" flow.
  - Universal deep-linking via `wallora://` and `https://wallora.app/*`.
  - TalkBack / VoiceOver screen-reader accessibility (`Semantics`) across all procedural canvases.
- **Production Store Hardening**:
  - ProGuard/R8 code minification and resource shrinking with reflection-safe rules.
  - Production release signing pipeline in `build.gradle.kts` with `key.properties.example` template and fallback to debug keys.
  - Android clear-text traffic ban via `network_security_config.xml` and iOS App Transport Security (`NSAppTransportSecurity`).
  - Multi-language internationalization (i18n) supporting English (`en`), Spanish (`es`), Japanese (`ja`), German (`de`), French (`fr`), and Hindi (`hi`).
  - Automated CI/CD pipeline in GitHub Actions running Flutter tests, Spring Boot Checkstyle, JUnit 5 integration tests, and Docker multi-stage builds.
- **Observability, Diagnostics & Performance Verification**:
  - Global error boundary defense (`ProductionCrashFallbackWidget`) replacing Flutter's red/grey screen of death with an obsidian dark recovery interface.
  - Thread-safe 100-event FIFO in-memory ring buffer (`AppDiagnostics`) recording lifecycle, BLoC, network, and crash breadcrumbs with zero PII leaks.
  - Interactive UI diagnostic viewer (`DiagnosticLogsSheet`) with one-click anonymized support report export to clipboard.
  - Non-intrusive outbound network diagnostic interceptor (`DiagnosticNetworkInterceptor`) tracking HTTP status codes and exceptions.
  - Canvas 60 FPS rendering performance benchmark suite (`test/benchmarks/canvas_performance_benchmark_test.dart`) validating 16.6ms frame budgets across all procedural painters.
  - End-to-End simulation test harness (`test/e2e/app_flow_e2e_test.dart`) and native integration test runner (`integration_test/app_e2e_test.dart`).
  - Pixel-perfect golden visual regression suite (`test/goldens/`) capturing master snapshots for all canvases and composite widgets.
