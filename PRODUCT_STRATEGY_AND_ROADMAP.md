# WALLORA ⚡
### *Make every screen yours.*
## Complete Product Strategy, Technical Architecture & Development Roadmap

**Product**: Wallora  
**Tagline**: *Make every screen yours.*  
**Platform**: Android & iOS / iPadOS  
**Primary Technology**: Flutter, Dart, Kotlin, Swift  
**Architecture**: Feature-first, Intent-Driven BLoC  
**Version**: 1.0.0  
**Date**: October 2026  

---

## 1. Executive Summary

The goal is to build a wallpaper application that combines static wallpapers and short video-based live wallpapers in a single experience.

Unlike traditional wallpaper applications that primarily display image grids, this application will allow users to discover beautiful images, explore short cinematic videos, preview wallpapers, save favorites, and apply supported wallpapers to their devices.

The application initially focuses on Android because Android supports native live wallpapers through its wallpaper service APIs, while supporting iPadOS/iOS via native share sheet integration (`UIActivityViewController` + `UIImage`) and Photos export.

The product includes three primary content experiences:
1. **Static Wallpapers**: High-quality images for home and lock screens.
2. **Live Wallpapers**: Short, optimized video wallpapers, generally 15–30 seconds long.
3. **Quote Wallpapers**: Static images with motivational quotes, customizable text, and typography.

The initial release focuses on a polished experience, a curated content catalog, reliable wallpaper application, and good performance on a broad range of Android devices.

Public creator uploads, advanced personalization, premium collections, and additional iOS functionality can be introduced after the core experience has been validated.

### Product Vision
Build a wallpaper discovery platform where users can find, preview, personalize, and apply wallpapers that reflect their interests and personality.

### Product Positioning
Discover wallpapers that match your style, from minimal static images to cinematic live backgrounds.

### Primary Differentiator
The combination of an attractive, short-video discovery experience with a unified catalog of static and live wallpapers. The application feels like a wallpaper discovery platform rather than simply a gallery of downloadable images.

---

## 2. Product Goals and Objectives

### 2.1 Primary Goals
- Provide an intuitive way to discover wallpapers.
- Support both static and live wallpapers.
- Make previewing and applying wallpapers straightforward.
- Provide a fast, responsive scrolling experience.
- Offer personalized wallpaper recommendations over time.
- Build a content system that can eventually support creators.
- Keep video playback optimized for battery, memory, and bandwidth.
- Create a foundation for sustainable monetization.

### 2.2 Secondary Goals
- Support favorites and collections.
- Enable wallpaper search and category browsing.
- Provide downloadable wallpapers for offline use.
- Support motivational quote wallpapers.
- Allow users to report inappropriate content.
- Introduce premium collections when there is sufficient demand.

### 2.3 Non-Goals for the Initial Release
Avoid expanding the first version into a social network.
The initial release does not need:
- Public comments.
- Direct messaging.
- Follower counts.
- Creator livestreaming.
- Complex social profiles.
- AI-generated wallpapers.
- An advanced recommendation engine.
- Multiple subscription tiers.
- A full creator marketplace.

---

## 3. Target Audience

1. **Anime and Gaming Enthusiasts**: Action aesthetics, combat spirit (*Hajime no Ippo: Makunouchi Creed*), futuristic neon environments.
2. **Minimalist and AMOLED Users**: Pure black wallpapers, dark gradients, abstract shapes, minimal typography, battery-conscious static backgrounds.
3. **Automotive Enthusiasts**: Sports cars, supercars, nocturnal highway acceleration, cinematic vehicle videos.
4. **Nature and Photography Enthusiasts**: Mountains, oceans, auroras, moving water, wildlife.
5. **Motivation and Productivity Users**: Motivational quotes, minimal typography, daily inspiration, focus-oriented backgrounds, customizable affirmations.

---

## 4. Product Scope and Feature Priorities

### Phase 1: Minimum Viable Product (Current)
- Onboarding & permissions.
- Discover feed & category filtering.
- Static wallpaper grid & vertical live wallpaper feed.
- Unified wallpaper preview.
- Native Android `WallpaperService` live wallpaper integration.
- iPadOS/iOS `IPadWallpaperDialog` & native "Use as Wallpaper" share sheet.
- Favorites & offline caching.
- Custom quote typography studio.
- Error handling, zero-battery-drain lifecycle, and 100% test coverage.

### Phase 2: Product Improvement
- Personalized recommendations & recently viewed history.
- Offline collections & download manager.
- Advanced quote customization & typography exports.
- Premium collections & remote configuration.
- Content reporting & lightweight admin dashboard.

### Phase 3: Platform Expansion
- Invite-only creator uploads.
- Creator profiles & moderation review queue.
- User-created collections.
- Subscription features.
- Expanded iOS support (Live Photo motion pairing).

---

## 5. User Experience and Navigation

### 5.1 Bottom Navigation Bar (4 Destinations)
1. **Discover**: Search bar, featured collection, trending, recommended for you, live feed, static grid.
2. **Categories**: Category browse & filter matrix.
3. **Favorites**: Bookmarked wallpapers list.
4. **Downloads**: Locally saved assets for offline use.

### 5.2 Live Wallpaper Feed
- 9:16 vertical swiping experience.
- One active video playing at a time; muted by default for battery savings.
- Videos pause immediately when off-screen.
- Clear Apply Wallpaper CTA, Favorite button, and Quote Studio button.

### 5.3 Unified Wallpaper Preview
- Preview static high-res or looping live video.
- Title, category, attribution, resolution, and duration.
- Favorite, Download, and Apply actions.

---

## 6. Android Live Wallpaper Implementation

- **Service**: Native `VideoWallpaperService.kt` (`WallpaperService`).
- **Engine**: SurfaceHolder-backed `MediaPlayer` with `VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING`.
- **Battery Optimization**: `onVisibilityChanged` instantly pauses decoding when the screen sleeps or another app is open (0% background drain).
- **Resilience**: Validates `surface.isValid` before attaching player; automatic fallback to bundled assets if user wipes local cache.
- **Broadcast Switching**: Seamlessly updates active wallpaper via `ACTION_UPDATE_WALLPAPER` without reopening system chooser.

---

## 7. iOS & iPadOS Strategy

- **Native Reality**: iOS does not permit continuous 3rd-party video wallpaper background daemons.
- **High-Res Frame Extraction**: `AppDelegate.swift` extracts full 4K/Retina `UIImage` from the video asset.
- **Native Share Sheet**: Passes `[UIImage]` to `UIActivityViewController` anchored to center for iPad, directly triggering Apple's native **"Use as Wallpaper"** (`UIActivity.ActivityType.setWallpaper`).
- **Photos Library**: Saves both the high-res image and looping video to Photos with `.addOnly` permission.
- **IPadWallpaperDialog**: Guides users step-by-step through the 3 iPadOS steps.

---

## 8. Technical Architecture & Tech Stack

| Layer | Technology |
| :--- | :--- |
| Cross-platform UI | Flutter (Dart 3.x) |
| State Management | `flutter_bloc` with Intent-Driven Development (IDD) |
| Local Preferences | `shared_preferences` |
| Native Android | Kotlin (`WallpaperService`, `MediaPlayer`) |
| Native iOS | Swift (`AVAssetImageGenerator`, `PHPhotoLibrary`, `UIActivityViewController`) |
| Communication | `MethodChannel` (`com.example.live_wallpaper/wallpaper`) |

---

## 9. Testing & Quality Assurance

- **Unit & BLoC Tests**: Intent handling, category filtering, favorites, custom quotes, user preferences.
- **Widget Tests**: `KineticQuoteOverlay`, `ShortsActionRail`, `IPadWallpaperDialog`.
- **Analyzer**: 0 lint warnings (`flutter analyze`).
- **Device Builds**: Validated on real Android devices & connected iPad (`ZMX iPad 8th Gen`).
