import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.demiks.teacher"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as string
            keyPassword = keystoreProperties["keyPassword"] as string
            storeFile = keystoreProperties["storeFile"] ? file(keystoreProperties["storeFile"] as string) : null
            storePassword = keystoreProperties["storePassword"] as string
        }
    }

    defaultConfig {
        applicationId = "com.demiks.teacher"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {            
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
