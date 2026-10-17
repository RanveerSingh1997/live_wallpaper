package com.example.live_wallpaper

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaPlayer
import android.os.Build
import android.service.wallpaper.WallpaperService
import android.util.Log
import android.view.SurfaceHolder
import java.io.File
import java.io.FileInputStream

class VideoWallpaperService : WallpaperService() {

    companion object {
        const val TAG = "VideoWallpaperService"
        const val ACTION_UPDATE_WALLPAPER = "com.example.live_wallpaper.UPDATE_WALLPAPER"
        const val PREFS_NAME = "live_wallpaper_prefs"
        const val KEY_VIDEO_PATH = "video_path"
        const val KEY_IS_MUTED = "is_muted"
    }

    override fun onCreateEngine(): Engine {
        return VideoEngine()
    }

    inner class VideoEngine : Engine() {
        private var mediaPlayer: MediaPlayer? = null
        private var isVisibleState = false
        private var isReceiverRegistered = false

        private val updateReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                Log.d(TAG, "Received wallpaper update broadcast")
                loadAndPlayVideo()
            }
        }

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            val filter = IntentFilter(ACTION_UPDATE_WALLPAPER)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    registerReceiver(updateReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
                } else {
                    registerReceiver(updateReceiver, filter)
                }
                isReceiverRegistered = true
            } catch (e: Exception) {
                Log.e(TAG, "Failed to register broadcast receiver", e)
            }
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            isVisibleState = visible
            try {
                if (visible) {
                    mediaPlayer?.start()
                } else {
                    mediaPlayer?.pause()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in onVisibilityChanged: visible=$visible", e)
            }
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            loadAndPlayVideo()
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
        }

        private fun loadAndPlayVideo() {
            val surface = surfaceHolder.surface
            if (surface == null || !surface.isValid) {
                Log.w(TAG, "Surface is invalid, skipping video playback.")
                return
            }

            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val videoPath = prefs.getString(KEY_VIDEO_PATH, null)
            val isMuted = prefs.getBoolean(KEY_IS_MUTED, true)

            var videoFile: File? = if (!videoPath.isNullOrEmpty()) File(videoPath) else null

            // Fallback recovery: if saved path does not exist, find any available wallpaper file
            if (videoFile == null || !videoFile.exists()) {
                Log.w(TAG, "Specified video file not found, searching fallback storage...")
                val candidate = applicationContext.filesDir.listFiles { _, name -> name.endsWith(".mp4") }?.firstOrNull()
                if (candidate != null && candidate.exists()) {
                    videoFile = candidate
                } else {
                    // Extract bundled default asset so wallpaper is NEVER blank
                    try {
                        val fallback = File(applicationContext.filesDir, "default_wallpaper.mp4")
                        if (!fallback.exists()) {
                            applicationContext.assets.open("flutter_assets/assets/videos/ippo_motivation.mp4").use { input ->
                                fallback.outputStream().use { output ->
                                    input.copyTo(output)
                                }
                            }
                        }
                        if (fallback.exists()) {
                            videoFile = fallback
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Fallback asset extraction failed", e)
                    }
                }
            }

            if (videoFile == null || !videoFile.exists()) {
                Log.e(TAG, "No valid video file could be prepared for wallpaper service.")
                return
            }

            try {
                mediaPlayer?.stop()
                mediaPlayer?.release()
                mediaPlayer = null

                val player = MediaPlayer()
                player.setSurface(surface)

                FileInputStream(videoFile).use { fis ->
                    player.setDataSource(fis.fd)
                }

                player.isLooping = true
                player.setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING)

                val volume = if (isMuted) 0f else 1f
                player.setVolume(volume, volume)

                player.setOnPreparedListener { mp ->
                    if (isVisibleState) {
                        mp.start()
                    }
                }

                player.setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error: what=$what extra=$extra")
                    true
                }

                player.prepareAsync()
                mediaPlayer = player
                Log.d(TAG, "Successfully loaded live wallpaper: ${videoFile.absolutePath}")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to load and play video", e)
                try {
                    mediaPlayer?.release()
                    mediaPlayer = null
                } catch (_: Exception) {}
            }
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            try {
                mediaPlayer?.stop()
                mediaPlayer?.release()
                mediaPlayer = null
            } catch (e: Exception) {
                Log.e(TAG, "Error cleaning up MediaPlayer on surface destroyed", e)
            }
        }

        override fun onDestroy() {
            super.onDestroy()
            if (isReceiverRegistered) {
                try {
                    unregisterReceiver(updateReceiver)
                    isReceiverRegistered = false
                } catch (e: Exception) {
                    Log.e(TAG, "Error unregistering receiver", e)
                }
            }
            try {
                mediaPlayer?.stop()
                mediaPlayer?.release()
                mediaPlayer = null
            } catch (e: Exception) {
                Log.e(TAG, "Error destroying MediaPlayer", e)
            }
        }
    }
}
