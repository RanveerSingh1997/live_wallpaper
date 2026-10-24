# Wallora — "Make every screen yours."
Developer & AI Agent Guidelines for the Wallora Codebase.

## 1. Brand Identity & Copy Standards
- **App Name**: `Wallora`
- **Tagline**: `"Make every screen yours."`
- **Aesthetic**: Premium obsidian black with fluid aurora neon gradients (cyan `#00E5FF`, violet `#D500F9`, amber `#FF5722`, emerald `#00E676`).
- **Cold Start**: Pure black native drawables and LaunchScreen storyboard to eliminate white flash before the animated splash screen mounts.

## 2. Architecture & State Management (Intent-Driven Development)
- **Unidirectional Data Flow (UDF)**:
  - **View**: Emits immutable `WallpaperIntent` events.
  - **BLoC**: Handles events in `WallpaperBloc` and emits immutable `WallpaperState`.
  - **Repository**: Encapsulates persistence, `SharedPreferences`, and platform bridges in `WallpaperRepository`.
  - **Platform Bridge**: Platform channels belong in `WallpaperServiceBridge` (`com.example.live_wallpaper/wallpaper`). Views must never call platform channels directly.

## 3. Flutter & Widget Conventions
- **Adaptive Switches**: Use `activeThumbColor` and `activeTrackColor` on `Switch.adaptive` (never deprecated `activeColor`).
- **Safe Modal Popping**: In dialogs and modal bottom sheets, always verify:
  `if (mounted && Navigator.of(context).canPop()) { Navigator.of(context).pop(); }`
- **Material Ancestors for ListTiles**: When building modal bottom sheets with `ListTile` items, use `Material(color: ..., child: ...)` instead of `Container(decoration: BoxDecoration(...))` to ensure ink reactions and splashes are properly displayed without occlusion.
- **Bounded Simulation Previews**: In phone simulation previews, ensure text badges and pills are wrapped in `Flexible` with `TextOverflow.ellipsis` to prevent `RenderFlex` horizontal overflow.
- **Color Serialization**: Use `Color.toARGB32()` for integer serialization and `Color(int)` for deserialization.

## 4. Performance & Battery Constraints
- **Zero Sleep Overhead**: The native Android `WallpaperService` and background auto-rotation loops must never hold wake-locks or consume CPU/GPU cycles when the screen is turned off.
- **Bandwidth Protection**: Auto-rotation downloads must observe the Wi-Fi only toggle.

## 5. Testing & Verification Mandate
- Any state or logic change requires unit tests in `test/blocs/wallpaper_bloc_test.dart`.
- Any new screen or modal requires widget tests in `test/widget_test.dart`.
- All tests must pass green (`flutter test` and `./mvnw test`) and `flutter analyze` must report 0 issues before changes are committed.

## 6. Linting & Code Structure Standards (See CODING_STRUCTURE.md)
- **Dart / Flutter Linting**: Strict rules in `analysis_options.yaml` (async safety, `unawaited_futures`, `use_build_context_synchronously`, widget const optimization). Enforced via `flutter analyze --fatal-infos --fatal-warnings`.
- **Java Backend Linting**: Strict rules in `backend/checkstyle.xml` (no wildcard imports, unused import prevention, bracket discipline). Enforced via `cd backend && ./mvnw checkstyle:check`.
- **Architectural Reference**: Refer to [CODING_STRUCTURE.md](file:///Users/zml-mac-ranveerg-01/flutterProject/live_wallpaper/CODING_STRUCTURE.md) for full directory layout and layer boundaries.
