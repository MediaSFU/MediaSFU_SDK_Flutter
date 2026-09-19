package com.example.example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.mediasfu/screen_wake_lock")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enable" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        result.success(mapOf("success" to true))
                    }
                    "disable" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        result.success(mapOf("success" to true))
                    }
                    "isEnabled" -> result.success(mapOf("enabled" to
                        ((window.attributes.flags and WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON) != 0)))
                    else -> result.notImplemented()
                }
            }
    }
}
