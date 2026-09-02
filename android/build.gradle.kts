allprojects {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://jitpack.io")
        maven(url = "https://developer.huawei.com/repo")
        maven(url = "https://developer.hihonor.com/repo")
        maven(url = "https://artifact.bytedance.com/repository/Volcengine/")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// 仅兜底：个别 Flutter 插件仍写死 compileSdk 30，与所依赖的 AndroidX 资源不兼容（如
// android:attr/lStar 需 API 31+）。此处只做「不低于 31」的补齐，用 max(当前, 31)，
// 不降级、不强行抬高已在用 34/36 等更高 compileSdk 的模块，避免影响主工程与其它插件。
gradle.beforeProject {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        val current = readCompileSdk(androidExt)
        val minCompileSdkForMergedResources = 31
        val sdk = maxOf(current, minCompileSdkForMergedResources)
        if (sdk == current) return@afterEvaluate
        try {
            androidExt.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                .invoke(androidExt, sdk)
        } catch (_: ReflectiveOperationException) {
            try {
                androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(androidExt, sdk)
            } catch (_: ReflectiveOperationException) {
                // 忽略无法识别的 Android 扩展
            }
        }
    }
}

fun readCompileSdk(androidExt: Any): Int {
    try {
        val v = androidExt.javaClass.getMethod("getCompileSdk").invoke(androidExt) ?: return 0
        return (v as Number).toInt()
    } catch (_: ReflectiveOperationException) {
        try {
            val v = androidExt.javaClass.getMethod("getCompileSdkVersion").invoke(androidExt) ?: return 0
            return when (v) {
                is Int -> v
                is String -> v.removePrefix("android-").toIntOrNull() ?: 0
                else -> (v as? Number)?.toInt() ?: 0
            }
        } catch (_: ReflectiveOperationException) {
            return 0
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
