# Flutter R8 / ProGuard Configuration Rules for Wallora

# Flutter Framework & Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Wallora Native Services & Engine Bridges
-keep class com.example.live_wallpaper.MainActivity { *; }
-keep class com.example.live_wallpaper.VideoWallpaperService { *; }
-keep class com.example.live_wallpaper.VideoWallpaperService$* { *; }

# Media & Video Player Plugin Reflection Rules
-keep class io.flutter.plugins.videoplayer.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# SharedPreferences & Core Android Plugins
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }

# Android WallpaperService lifecycle preservation
-keep public class * extends android.service.wallpaper.WallpaperService {
    public <init>();
    public <methods>;
}
-keep public class * extends android.service.wallpaper.WallpaperService$Engine {
    public <init>(...);
    public <methods>;
}

# Preserve Line Numbers for Crashlytics / Production Sentry Symbolication
-keepattributes SourceFile,LineNumberTable
