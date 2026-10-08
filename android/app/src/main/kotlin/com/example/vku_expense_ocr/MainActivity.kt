package com.example.vku_expense_ocr

import android.content.Context
import android.os.BatteryManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "vn.edu.vku/device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getBatteryLevel") {
                    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    result.success(batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY))
                } else {
                    result.notImplemented()
                }
            }
    }
}
