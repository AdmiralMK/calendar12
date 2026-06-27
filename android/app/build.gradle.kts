plugins {
    id("com.android.application")
    // ❌ УБРАЛИ: id("kotlin-android") — Flutter применит Kotlin автоматически
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.calendar12"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ✅ ЗАМЕНИЛИ kotlinOptions на современный синтаксис
    // kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() } // <-- было

    defaultConfig {
        applicationId = "com.example.calendar12"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
                        // ✅ Уменьшение размера APK
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// ✅ Современный способ настройки Kotlin (вместо kotlinOptions)
kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}