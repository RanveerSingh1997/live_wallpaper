package com.example.live_wallpaper

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.live_wallpaper/wallpaper"
        private const val TAG = "MainActivity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setLiveWallpaper" -> {
                    val videoPath = call.argument<String>("videoPath")
                    val isMuted = call.argument<Boolean>("isMuted") ?: true

                    if (videoPath.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "videoPath cannot be null or empty", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val prefs = getSharedPreferences(VideoWallpaperService.PREFS_NAME, Context.MODE_PRIVATE)
                        prefs.edit()
                            .putString(VideoWallpaperService.KEY_VIDEO_PATH, videoPath)
                            .putBoolean(VideoWallpaperService.KEY_IS_MUTED, isMuted)
                            .apply()

                        val isAlreadyActive = checkIsWallpaperActive()

                        if (isAlreadyActive) {
                            // Service is already set as current wallpaper. Broadcast update to switch video immediately!
                            val updateIntent = Intent(VideoWallpaperService.ACTION_UPDATE_WALLPAPER)
                            updateIntent.setPackage(packageName)
                            sendBroadcast(updateIntent)
                            result.success(mapOf("status" to "updated_active", "isAlreadyActive" to true))
                        } else {
                            // Launch system live wallpaper preview chooser
                            val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
                                putExtra(
                                    WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                                    ComponentName(this@MainActivity, VideoWallpaperService::class.java)
                                )
                            }
                            try {
                                startActivity(intent)
                                result.success(mapOf("status" to "opened_chooser", "isAlreadyActive" to false))
                            } catch (e: Exception) {
                                Log.w(TAG, "ACTION_CHANGE_LIVE_WALLPAPER failed, attempting fallback chooser", e)
                                val fallbackIntent = Intent(WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER)
                                startActivity(fallbackIntent)
                                result.success(mapOf("status" to "opened_chooser_fallback", "isAlreadyActive" to false))
                            }
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to set live wallpaper", e)
                        result.error("SET_WALLPAPER_FAILED", e.localizedMessage, null)
                    }
                }

                "isWallpaperActive" -> {
                    result.success(checkIsWallpaperActive())
                }

                "setAudioMuted" -> {
                    val isMuted = call.argument<Boolean>("isMuted") ?: true
                    val prefs = getSharedPreferences(VideoWallpaperService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().putBoolean(VideoWallpaperService.KEY_IS_MUTED, isMuted).apply()

                    val updateIntent = Intent(VideoWallpaperService.ACTION_UPDATE_WALLPAPER)
                    updateIntent.setPackage(packageName)
                    sendBroadcast(updateIntent)

                    result.success(true)
                }

                "openLiveWallpaperChooser" -> {
                    try {
                        val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
                            putExtra(
                                WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                                ComponentName(this@MainActivity, VideoWallpaperService::class.java)
                            )
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        val fallbackIntent = Intent(WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER)
                        startActivity(fallbackIntent)
                        result.success(true)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkIsWallpaperActive(): Boolean {
        return try {
            val wm = WallpaperManager.getInstance(applicationContext)
            val info = wm.wallpaperInfo
            info != null && info.serviceName == VideoWallpaperService::class.java.name
        } catch (e: Exception) {
            Log.e(TAG, "Error checking wallpaper status", e)
            false
        }
    }
}
