import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/curated_shorts_data.dart';
import '../models/motivational_short.dart';
import '../services/wallpaper_service_bridge.dart';

class WallpaperRepository {
  final WallpaperServiceBridge _bridge;
  final SharedPreferences prefs;

  static const String _keyFavorites = 'favorite_short_ids';
  static const String _keyActiveId = 'active_wallpaper_id';
  static const String _keyCustomQuotesPrefix = 'custom_quote_';
  static const String _keyUserPreferences = 'user_preferred_categories';
  static const String _keyTextOverlayEnabled = 'text_overlay_enabled_by_default';

  WallpaperRepository({
    WallpaperServiceBridge? bridge,
    required this.prefs,
  }) : _bridge = bridge ?? WallpaperServiceBridge();

  /// Returns list of all curated motivational shorts.
  List<MotivationalShort> getCuratedShorts() {
    return CuratedShortsData.shorts;
  }

  /// Returns set of user preferred wallpaper categories.
  Set<String> getUserPreferences() {
    final list = prefs.getStringList(_keyUserPreferences);
    if (list != null && list.isNotEmpty) {
      return list.toSet();
    }
    // Default preferences: Anime, Nature, Motivation
    return {'Anime & Gaming', 'Nature & Scenery', 'Motivation & Mindset'};
  }

  /// Saves user preferred categories.
  Future<void> saveUserPreferences(Set<String> preferences) async {
    await prefs.setStringList(_keyUserPreferences, preferences.toList());
  }

  /// Checks if text overlays should be shown by default.
  bool isTextOverlayEnabledByDefault() {
    return prefs.getBool(_keyTextOverlayEnabled) ?? true;
  }

  /// Toggles global text overlay preference.
  Future<void> setTextOverlayEnabled(bool enabled) async {
    await prefs.setBool(_keyTextOverlayEnabled, enabled);
  }

  /// Returns set of favorite IDs.
  Set<String> getFavorites() {
    final list = prefs.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  /// Toggles favorite status for a short.
  Future<Set<String>> toggleFavorite(String shortId) async {
    final current = getFavorites();
    if (current.contains(shortId)) {
      current.remove(shortId);
    } else {
      current.add(shortId);
    }
    await prefs.setStringList(_keyFavorites, current.toList());
    return current;
  }

  /// Returns all stored custom quotes by shortId.
  Map<String, String> getCustomQuotes() {
    final Map<String, String> map = {};
    for (final short in CuratedShortsData.shorts) {
      final saved = prefs.getString('$_keyCustomQuotesPrefix${short.id}');
      if (saved != null && saved.isNotEmpty) {
        map[short.id] = saved;
      }
    }
    return map;
  }

  /// Saves a user-customized quote for a given short.
  Future<void> saveCustomQuote(String shortId, String quote) async {
    await prefs.setString('$_keyCustomQuotesPrefix$shortId', quote);
  }

  /// Returns the ID of the currently active wallpaper.
  String? getActiveWallpaperId() {
    return prefs.getString(_keyActiveId);
  }

  /// Prepares the video asset by extracting it to local device storage.
  /// Android's native MediaPlayer requires a physical file path.
  Future<String> prepareVideoFile(MotivationalShort short) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String targetPath = '${dir.path}/wallpaper_${short.id}.mp4';
    final File targetFile = File(targetPath);

    if (await targetFile.exists() && await targetFile.length() > 0) {
      return targetFile.path;
    }

    // Copy bytes from Flutter asset bundle to application directory
    final ByteData byteData = await rootBundle.load(short.videoAssetPath);
    final Uint8List bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    await targetFile.writeAsBytes(bytes, flush: true);

    return targetFile.path;
  }

  /// Applies the motivational short as a looping live wallpaper.
  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  }) async {
    final String localVideoPath = await prepareVideoFile(short);
    final result = await _bridge.setLiveWallpaper(
      videoPath: localVideoPath,
      isMuted: isMuted,
    );

    if (result['status'] == 'updated_active' ||
        result['status'] == 'opened_chooser' ||
        result['status'] == 'opened_chooser_fallback' ||
        result['status'] == 'saved_to_photos') {
      await prefs.setString(_keyActiveId, short.id);
    }

    return result;
  }

  /// Checks if wallpaper is actively running on device.
  Future<bool> isWallpaperActiveOnDevice() async {
    return await _bridge.isWallpaperActive();
  }

  /// Shares video via native iPad/iOS share sheet with "Use as Wallpaper" option.
  Future<void> shareVideo(MotivationalShort short) async {
    final String localVideoPath = await prepareVideoFile(short);
    await _bridge.shareVideo(localVideoPath);
  }

  /// Opens the iPad Photos app directly.
  Future<void> openPhotos() async {
    await _bridge.openPhotos();
  }

  /// Toggles audio for wallpaper.
  Future<void> setWallpaperAudioMuted(bool isMuted) async {
    await _bridge.setAudioMuted(isMuted);
  }

  /// Re-opens chooser.
  Future<void> openChooser() async {
    await _bridge.openChooser();
  }
}
