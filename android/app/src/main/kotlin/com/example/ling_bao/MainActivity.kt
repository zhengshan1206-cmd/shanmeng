package com.example.ling_bao

import android.view.Window
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.ByPlugin
import io.flutter.plugins.GeneratedPluginRegistrant

/** 与参考工程 GlobalConstant / by_channel_api 一致 */
private object G {
    const val FLUTTER_CHANNEL_NAME = "com.by.ve.bridge"
    const val SUCCESS = 200
    const val APP_INIT = "appInit"
    const val OCEANENGINE_EVENT = "oceanengineEvent"
    const val APP_DEVICE_INFO = "appDeviceInfo"
}

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            G.FLUTTER_CHANNEL_NAME,
        ).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            G.APP_INIT -> {
                val appId = call.argument<String>("appid")
                val channel = call.argument<String>("channel")
                ByPlugin.iniBDConvert(applicationContext, this, appId, channel)
                result.success(ByPlugin.baserResult(G.SUCCESS))
            }
            G.OCEANENGINE_EVENT -> {
                val params = call.argument<String>("params")
                ByPlugin.oceanengineEvent(params)
                result.success(ByPlugin.baserResult(G.SUCCESS))
            }
            G.APP_DEVICE_INFO -> {
                ByPlugin.getAndroidDeviceInfo(this) { oId, androidId ->
                    result.success(
                        ByPlugin.baserResult(
                            G.SUCCESS,
                            mapOf(
                                "oId" to oId,
                                "androidId" to androidId,
                            ),
                        ),
                    )
                }
            }
            else -> {}
        }
    }
}
