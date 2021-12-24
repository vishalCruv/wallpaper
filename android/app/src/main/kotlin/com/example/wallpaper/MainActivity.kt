package com.example.wallpaper
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.IOException
import android.app.WallpaperManager
import android.graphics.BitmapFactory
import java.io.File
import android.os.Build
import android.annotation.TargetApi
import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.Log


class MainActivity: FlutterActivity() {
    private val CHANNEL = "wallpaper"
  
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
      super.configureFlutterEngine(flutterEngine)
      MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        call, result ->
        // Note: this method is invoked on the main thread.
        // TODO
        if (call.method == "setWallpaper") {
            val arguments = call.arguments as ArrayList<*>
            val setWallpaper = setWallpaper(arguments[0] as String, applicationContext, arguments[1] as Int)
    
            if (setWallpaper == 0) {
              result.success(setWallpaper)
            } else {
              result.error("UNAVAILABLE", "", null)
            }
          } else {
                result.notImplemented()
          }
      }
    }
    fun setWallpaper(path: String, applicationContext: Context, wallpaperType: Int): Int {
        var setWallpaper =1
        val bitmap = BitmapFactory.decodeFile(path)
        val wm: WallpaperManager? = WallpaperManager.getInstance(applicationContext)
        setWallpaper = 
        try {
          wm?.setBitmap(bitmap, null, true, wallpaperType)
          0
        } 
        catch (e: IOException) {
          1
        }
    
        return setWallpaper
      }
}
