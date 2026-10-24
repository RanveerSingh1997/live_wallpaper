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
  - Automated CI/CD pipeline in GitHub Actions running 382 Flutter tests, Spring Boot Checkstyle, JUnit 5 integration tests, and Docker multi-stage builds.
