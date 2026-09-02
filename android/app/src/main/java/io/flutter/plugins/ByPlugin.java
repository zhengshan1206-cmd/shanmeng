package io.flutter.plugins;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import com.bytedance.ads.convert.BDConvert;
import com.bytedance.ads.convert.callback.BDConvertLifecycleCallback;
import com.bytedance.ads.convert.config.BDConvertConfig;
import com.bytedance.ads.convert.depend.CustomAndroidIDCallback;
import com.bytedance.ads.convert.depend.CustomOaidCallback;
import com.bytedance.ads.convert.event.ConvertReportHelper;
import com.github.gzuliyujiang.oaid.DeviceID;
import com.github.gzuliyujiang.oaid.IGetter;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;


public class ByPlugin {

    public interface ByPluginCallbackListener {
        void onFinish(String oId, String androidId);
    }

    private static Boolean isIniBDConvert = false;
    private static String cachedOaid = "";
    private static String cachedAndroidId = "";

    /**
     * 初始化巨量归因SDK（需在用户同意隐私政策后调用）
     */
    public static void iniBDConvert(Context context, Activity activity, String appId, String channel) {
        if (isIniBDConvert) {
            Log.d("iniBDConvert", "repeat");
            return;
        }
        // 先获取OAID和android_id，再通过CustomCallback注入SDK，避免重复采集
        getAndroidDeviceInfo(activity, (oId, androidId) -> {
            cachedOaid = oId != null ? oId : "";
            cachedAndroidId = androidId != null ? androidId : "";
            initBDConvertInternal(context, activity, appId, channel);
        });
    }

    private static void initBDConvertInternal(Context context, Activity activity, String appId, String channel) {
        try {
            if (isIniBDConvert) {
                return;
            }
            isIniBDConvert = true;
            if (channel == null || channel.isEmpty()) {
                channel = "channel";
            }
            Log.d("iniBDConvert", "InitConfig AppId: " + appId + ", Channel: " + channel);

            BDConvertConfig config = new BDConvertConfig();
            // 隐私弹窗后再手动发送启动事件
            config.setAutoSendLaunchEvent(false);
            config.setEnableLog(true);
            config.setPlaySessionEnable(true);
            config.setEnableOAID(true);
            config.setCustomOaidCallback(new CustomOaidCallback() {
                @Override
                public String get() {
                    return cachedOaid;
                }
            });
            config.setCustomAndroidIDCallback(new CustomAndroidIDCallback() {
                @Override
                public String get() {
                    return cachedAndroidId;
                }
            });
            config.setLifecycleCallback(new BDConvertLifecycleCallback() {
                @Override
                public void onInitSuccess() {
                    Log.d("iniBDConvert", "onInitSuccess");
                }

                @Override
                public void onInitFailure(int code, Throwable throwable) {
                    Log.e("iniBDConvert", "onInitFailure: " + code, throwable);
                }

                @Override
                public void onEventSendSuccess(String eventName, String eventData) {
                    Log.d("iniBDConvert", "onEventSendSuccess: " + eventName);
                }

                @Override
                public void onEventSendFailure(String eventName, int code, String msg, Throwable throwable) {
                    Log.e("iniBDConvert", "onEventSendFailure: " + eventName + ", code=" + code + ", msg=" + msg, throwable);
                }

                @Override
                public void onOtherError(int code, Throwable throwable) {
                    Log.e("iniBDConvert", "onOtherError: " + code, throwable);
                }
            });

            BDConvert.INSTANCE.init(context, config, activity);
            BDConvert.INSTANCE.sendLaunchEvent(context);
            Log.d("iniBDConvert", "OK  " + "AndroidId: " + cachedAndroidId + " OAID: " + cachedOaid);
        } catch (Exception e) {
            isIniBDConvert = false;
            Log.e("iniBDConvert", "ERROR", e);
        }
    }

    /**
     * SDK事件回传
     */
    public static void oceanengineEvent(String eventString) {
        Log.d("iniBDConvert Event", eventString);
        try {
            JSONObject event = new JSONObject(eventString);
            String e = event.getString("event");
            if (event.has("_auto_id_")) {
                event.remove("_auto_id_");
            }
            if (e.equals("register")) {
                String way = event.getString("way");
                ConvertReportHelper.onEventRegister(way, true);
            } else if (e.equals("purchase")) {
                String goodType = event.getString("good_type");
                String goodName = event.getString("good_name");
                String goodId = event.getString("good_id");
                int goodNum = event.getInt("good_num");
                String payType = event.getString("pay_type");
                String currency = event.getString("currency");
                double money = event.getDouble("money");
                int intMoney = (int) money;
                ConvertReportHelper.onEventPurchase(goodType, goodName, goodId, goodNum, payType, currency, true, intMoney);
            } else if (e.equals("game_addiction")) {
                org.json.JSONObject paramsObj = new org.json.JSONObject();
                try {
                    String originEvent = event.getString("origin_event");
                    paramsObj.put("origin_event", originEvent);
                } catch (Exception ex) {
                    // ignore
                }
                ConvertReportHelper.onEventV3("game_addiction", paramsObj);
            } else {
                try {
                    event.remove("event");
                    String eventStr = event.toString();
                    org.json.JSONObject paramsObj = new org.json.JSONObject(eventStr);
                    ConvertReportHelper.onEventV3(e, paramsObj);
                    Log.d("iniBDConvert onEventV3", e + ":" + eventStr);
                } catch (Exception ex) {
                    Log.e("iniBDConvert onEventV3", ex.getMessage());
                }
            }
        } catch (Exception e) {
            Log.e("iniBDConvert onEventV3", e.getMessage());
        }
    }

    public static void getAndroidDeviceInfo(Activity context, ByPluginCallbackListener byPluginCallbackListener) {
        String androidId = "";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
            try {
                androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
            } catch (Exception e) {
                androidId = "";
            }
        }

        String finalAndroidId = androidId;
        DeviceID.getOAID(context, new IGetter() {
            @Override
            public void onOAIDGetComplete(String result) {
                if (byPluginCallbackListener != null) {
                    byPluginCallbackListener.onFinish(result, finalAndroidId);
                }
            }

            @Override
            public void onOAIDGetError(Exception error) {
                if (byPluginCallbackListener != null) {
                    byPluginCallbackListener.onFinish("", finalAndroidId);
                }
            }
        });
    }

    public static Map baserResult(int code, String msg) {
        HashMap hashMap = new HashMap();
        hashMap.put("code", code);
        hashMap.put("msg", msg);
        return hashMap;
    }

    public static Map baserResult(int code, Map data) {
        HashMap hashMap = new HashMap();
        hashMap.put("code", code);
        hashMap.put("data", data);
        return hashMap;
    }

    public static Map baserResult(int code) {
        HashMap hashMap = new HashMap();
        hashMap.put("code", code);
        return hashMap;
    }
}
