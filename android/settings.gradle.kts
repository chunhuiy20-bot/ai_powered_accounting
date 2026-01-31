pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // 🟢 1. Flutter 引擎插件镜像 (必须加这个)
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }

        // 阿里云镜像
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }

        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

dependencyResolutionManagement {
    // 强制使用这里的配置
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        // 🟢 2. 关键修复：Flutter 引擎依赖镜像 (解决 io.flutter 找不到的问题)
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }

        // 阿里云镜像 (解决其他第三方包慢)
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }

        google()
        mavenCentral()
    }
}

include(":app")
