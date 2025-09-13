package com.pandora.core

import androidx.preference.PreferenceManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import pandora.a123.PandoraWidgetProvider

class MainActivity : FlutterActivity() {
    private val channelName = "pandora/actions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        val latestNote: String? = call.argument("latestNote")
                        if (latestNote != null) {
                            val prefs = PreferenceManager.getDefaultSharedPreferences(this)
                            prefs.edit().putString("latest_note", latestNote).apply()
                            PandoraWidgetProvider.updateAll(this)
                            result.success(true)
                        } else {
                            result.error("ARGUMENT_ERROR", "latestNote is required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
