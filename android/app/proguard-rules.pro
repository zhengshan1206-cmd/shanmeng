
# 友盟
-keep class com.umeng.** {*;}
-keep class org.repackage.** {*;}
-keep class com.uyumao.** { *; }
-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}


-dontwarn com.cmic.gen.sdk.**
-keep class com.cmic.gen.sdk.**{*;}
-dontwarn com.sdk.**
-keep class com.sdk.** { *;}
-dontwarn com.unikuwei.mianmi.account.shield.**
-keep class com.unikuwei.mianmi.account.shield.** {*;}
-keep class cn.com.chinatelecom.account.api.**{*;}

# 字节跳动SDK混淆保护规则
-dontwarn com.bytedance.**
-keep class com.bytedance.** { *; }
-keep class com.bytedance.ads.** { *; }
-keep class com.bytedance.applog.** { *; }
-keep class com.bytedance.ads.convert.** { *; }
-keep class com.bytedance.ads.convert.broadcast.** { *; }
-keep class com.bytedance.ads.convert.broadcast.common.** { *; }

# 保护EncryptionTools类及其方法
-keep class com.bytedance.ads.convert.broadcast.common.EncryptionTools {
    *;
}
-keepclassmembers class com.bytedance.ads.convert.broadcast.common.EncryptionTools {
    public static java.lang.String bytesToHex(byte[]);
    public static byte[] hexToBytes(java.lang.String);
}

# 保护EffectUtil类
-keep class com.illusion.light.EffectUtil {
    *;
}

# 保护RangersAppLog相关类
-keep class com.bytedance.applog.** { *; }
-keep class com.bytedance.applog.game.** { *; }

# 保护OAID相关类
-keep class com.github.gzuliyujiang.** { *; }
-keep class com.huawei.hms.** { *; }
-keep class com.hihonor.mcs.** { *; }

# OAID：已 exclude ads-identifier 依赖时，Honor/Huawei 广告 ID 类不在 classpath，
# R8 会报 Missing class；按 AGP 生成的 missing_rules 仅抑制告警即可（运行时走反射/分支）。
-dontwarn com.hihonor.ads.identifier.AdvertisingIdClient$Info
-dontwarn com.hihonor.ads.identifier.AdvertisingIdClient
-dontwarn com.huawei.hms.ads.identifier.AdvertisingIdClient$Info
-dontwarn com.huawei.hms.ads.identifier.AdvertisingIdClient

# 通用保护规则
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# 保护native方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保护枚举
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 忽略谷歌Play SplitCompat相关缺失类（非谷歌商店发布）
-dontwarn com.google.android.play.core.**

# R8 missing_rules.txt（自动生成）：抑制 BouncyCastle 缺失告警（同时建议在依赖中补齐 org.bouncycastle.*）
#-dontwarn org.bouncycastle.crypto.CipherParameters
#-dontwarn org.bouncycastle.crypto.InvalidCipherTextException
#-dontwarn org.bouncycastle.crypto.digests.SM3Digest
#-dontwarn org.bouncycastle.crypto.engines.SM2Engine
#-dontwarn org.bouncycastle.crypto.params.ECDomainParameters
#-dontwarn org.bouncycastle.crypto.params.ECPublicKeyParameters
#dontwarn org.bouncycastle.crypto.params.ParametersWithRandom
#-dontwarn org.bouncycastle.jce.ECNamedCurveTable
#-dontwarn org.bouncycastle.jce.spec.ECNamedCurveParameterSpec
#-dontwarn org.bouncycastle.jce.spec.ECParameterSpec
#-dontwarn org.bouncycastle.math.ec.ECCurve
#-dontwarn org.bouncycastle.math.ec.ECPoint
-dontwarn org.bouncycastle.**


# 保留 Flutter 框架相关类
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }