import com.android.build.gradle.BaseExtension
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

var localProperties = Properties()
var localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.bufferedReader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

var flutterVersionCode = localProperties.getProperty("flutter.versionCode")
if (flutterVersionCode == null) {
    flutterVersionCode = "1"
}

var flutterVersionName = localProperties.getProperty("flutter.versionName")
if (flutterVersionName == null) {
    flutterVersionName = "1.0"
}

var keystoreProperties = Properties()
var keystorePropertiesFile = rootProject.file("app/key/keystore.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}


android {
    namespace = "com.example.ling_bao"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zdrawai.flashai"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties.getProperty("storeFile") ?: "")
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true  // 启用代码混淆（可选）
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
        
        // Debug模式通常使用默认签名，无需额外配置
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")

    // 归因相关 AAR（参考项目同目录 libs 的接入方式）
    implementation("com.bytedance.ads:AppConvert:2.0.4")
    // OAID 依赖：与参考工程保持一致，显式补齐华为/荣耀广告标识服务运行时依赖。
    implementation("com.github.gzu-liyujiang:Android_CN_OAID:4.2.8") {
        exclude(group = "com.hihonor.mcs", module = "ads-identifier")
        exclude(group = "com.huawei.hms", module = "ads-identifier")
    }
    implementation("com.huawei.hms:ads-identifier:3.4.62.300")
    implementation("com.hihonor.mcs:ads-identifier:1.0.2.301")
}
