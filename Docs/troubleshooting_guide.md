# Simple Step Flutter - Troubleshooting Guide

## Overview

This document captures all the issues encountered during development and their solutions. Use this as a reference when recreating the app or troubleshooting similar Health Connect (Android) and HealthKit (iOS) integration problems.

## Cross-Platform Implementation Notes

This app now supports both:
- **Android**: Health Connect integration
- **iOS**: HealthKit integration

The same Flutter codebase automatically detects the platform and uses the appropriate health system.

## Issues Encountered and Solutions

### 1. Gradle Wrapper Corruption (Build Failure)

**Issue:** 
```
FAILURE: Build failed with an exception.
* What went wrong:
Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'.
> Could not resolve all task dependencies for configuration ':app:debugCompileClasspath'.
> Could not resolve project :health.
> Could not resolve project :health.
> zip END header not found
```

**Root Cause:** Corrupted Gradle wrapper files due to unstable internet connection during initial Flutter project creation.

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

**Key Learning:** Ensure stable internet connection during Flutter project initialization. If Gradle wrapper gets corrupted, clean and regenerate.

---

### 2. MinSdk Version Compatibility

**Issue:**
```
FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:checkDebugAarMetadata'.
> A failure occurred while executing com.android.build.gradle.internal.tasks.CheckAarMetadataTask$CheckAarMetadataDelegate
> The minSdk version (24) specified in a dependency's AAR metadata is greater than this module's minSdk version (16).
```

**Root Cause:** Health Connect requires minimum Android API level 26, but the default Flutter project was set to API 16.

**Solution:** Update `android/app/build.gradle.kts`:
```kotlin
android {
    compileSdk = 36  // Updated
    ndkVersion = "26.1.10909125"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = '11'
    }

    defaultConfig {
        applicationId = "com.example.simple_step_flutter"
        minSdk = 26  // Changed from 24 to 26
        targetSdk = 36  // Updated
        versionCode = 1
        versionName = "1.0"
    }
}
```

**Key Learning:** Health Connect requires Android API 26+. Always check dependency requirements and update minSdk accordingly.

---

### 3. MainActivity Compatibility

**Issue:** Health plugin compatibility issues with default MainActivity.

**Root Cause:** The health plugin requires FlutterFragmentActivity instead of FlutterActivity for proper Health Connect integration.

**Solution:** Update `android/app/src/main/kotlin/.../MainActivity.kt`:
```kotlin
package com.example.simple_step_flutter

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}
```

**Key Learning:** Some Flutter plugins require specific Activity types. Check plugin documentation for requirements.

---

### 4. Health Connect Permission System Issues

**Issue:** Despite requesting permissions through the Flutter health plugin, the Android system was denying access with:
```
java.lang.SecurityException: Caller doesn't have android.permission.health.READ_STEPS
```

The Flutter plugin reported permissions as granted, but the Android system rejected API calls.

**Root Cause:** Health Connect uses a different permission system than traditional Android permissions. It requires specific manifest configuration and activity-alias setup.

**Multiple Attempted Solutions (that didn't work):**
1. Traditional Android permissions in manifest
2. Multiple permission request methods in Flutter code
3. Different health plugin API calls
4. Legacy health permissions

**Final Working Solution:** 

Updated `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Health Connect permissions -->
    <uses-permission android:name="android.permission.health.READ_STEPS" />
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />

    <application
        android:label="simple_step_flutter"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Health Connect intent filter -->
        <activity-alias
            android:name="ViewPermissionUsageActivity"
            android:exported="true"
            android:targetActivity=".MainActivity"
            android:permission="android.permission.START_VIEW_PERMISSION_USAGE">
            <intent-filter>
                <action android:name="android.intent.action.VIEW_PERMISSION_USAGE" />
                <category android:name="android.intent.category.HEALTH_PERMISSIONS" />
            </intent-filter>
        </activity-alias>
        
        <!-- Rest of application configuration -->
    </application>
    
    <!-- Health Connect queries -->
    <queries>
        <package android:name="com.google.android.apps.healthdata" />
        <intent>
            <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
        </intent>
    </queries>
</manifest>
```

Updated `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  health: ^13.1.1  # Updated to latest version
```

**Key Learning:** Health Connect is not traditional Android permissions. It requires:
- Specific activity-alias configuration
- Health Connect queries section
- Latest version of health plugin (13.1.1+)
- Simplified permission declarations

---

### 5. Flutter Health Plugin Version Compatibility

**Issue:** Earlier versions of the health plugin (12.x) had incomplete Health Connect support.

**Solution:** Upgrade to health plugin version 13.1.1 which has better Health Connect integration.

**Key Learning:** Health Connect is relatively new. Always use the latest health plugin version for best compatibility.

---

### 6. iOS HealthKit Permission Setup

**Issue:** iOS devices may not have the proper HealthKit permissions configured in Info.plist.

**Root Cause:** HealthKit requires specific permission declarations in Info.plist to access health data.

**Solution:** Update `ios/Runner/Info.plist`:

```xml
<!-- HealthKit permissions for iOS -->
<key>NSHealthShareUsageDescription</key>
<string>This app needs access to step count data to display your daily steps on the screen.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app needs access to step count data to display your daily steps on the screen.</string>
```

**Key Learning:** iOS requires explicit permission descriptions in Info.plist for HealthKit access. The description should clearly explain why the app needs health data access.

---

### 7. Cross-Platform Platform Detection

**Implementation:** The app automatically detects the platform and adjusts behavior accordingly:

```dart
import 'dart:io' show Platform;

String platformName = Platform.isIOS ? 'HealthKit' : 'Health Connect';
```

**Key Learning:** Single codebase can handle both platforms by detecting the runtime platform and adjusting messages, button text, and debugging information accordingly.

---

## Debugging Techniques Used

### 1. Console Monitoring
Monitor Flutter console output for Health Connect specific messages:
```bash
flutter run
# Look for these indicators:
# SUCCESS: "Health Connect permissions were granted!"
# FAILURE: "Health Connect permissions were not granted!"
# DATA: "Step data point: X steps at YYYY-MM-DD"
```

### 2. Permission State Debugging
Add debug information to Flutter app to track permission states:
```dart
setState(() {
  _debugInfo.add('Permission check result: $hasPermissions');
  _debugInfo.add('Authorization result: $authorized');
});
```

### 3. Multiple Permission Request Methods
Implement fallback permission request methods to identify which approach works:
```dart
// Method 1: Standard READ
bool requested = await Health().requestAuthorization(
  types,
  permissions: [HealthDataAccess.READ],
);

// Method 2: READ_WRITE if READ fails
bool requested = await Health().requestAuthorization(
  types,
  permissions: [HealthDataAccess.READ_WRITE],
);
```

---

## Success Indicators

When everything is working correctly, you should see:
1. Console output: `Health Connect permissions were granted!`
2. Console output: `Permissions granted: [android.permission.health.READ_STEPS]`
3. Step data logs: `Step data point: X steps at YYYY-MM-DD HH:MM:SS`
4. App displays actual step count on white screen

---

## Quick Resolution Checklist

When recreating this app or facing similar issues:

1. ✅ **Build Issues:** Ensure stable internet, run `flutter clean && flutter pub get`
2. ✅ **MinSdk:** Set `minSdk = 26` in `android/app/build.gradle.kts`
3. ✅ **MainActivity:** Use `FlutterFragmentActivity` instead of `FlutterActivity`
4. ✅ **Health Plugin:** Use version `^13.1.1` or latest
5. ✅ **Manifest:** Include Health Connect activity-alias and queries sections
6. ✅ **Permissions:** Use Health Connect permission format, not traditional Android permissions
7. ✅ **Testing:** Monitor console for permission success/failure messages

---

## Environment Details

**Working Configuration:**
- Flutter SDK: 3.35.1
- Dart: Latest stable
- Android SDK: 36.0.0 (for Android)
- Xcode: Latest (for iOS)
- Health Plugin: 13.1.1
- Target Devices: 
  - Android with Health Connect support (API 26+)
  - iOS with HealthKit support (iOS 8.0+)
- Test Devices: 
  - Android: Pixel 6 with Health Connect app installed
  - iOS: Any iPhone/iPad with Health app

---

## Final Notes

The key breakthrough was understanding that Health Connect (Android) is not traditional Android permissions - it's a separate system with its own permission flow. Similarly, iOS HealthKit requires proper Info.plist configuration.

**Critical Success Factors:**
- **Android**: Activity-alias configuration and latest health plugin version
- **iOS**: Proper NSHealthShareUsageDescription in Info.plist
- **Cross-platform**: Single codebase with platform detection

This app now successfully reads real step data from both Health Connect (Android) and HealthKit (iOS), displaying it on a white screen with black numbers, exactly as specified in the original requirements. The cross-platform implementation maintains the same user experience on both platforms while handling platform-specific health integrations seamlessly.
