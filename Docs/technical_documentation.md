# Simple Step Flutter - Technical Documentation

## Project Structure

This Flutter app follows a minimal structure focused on displaying step count from Health Connect (Android) and HealthKit (iOS).

### Key Files

- `lib/main.dart` - Main application code containing the step counter logic with cross-platform support
- `pubspec.yaml` - Project dependencies and configuration
- `android/app/src/main/AndroidManifest.xml` - Android permissions for Health Connect
- `ios/Runner/Info.plist` - iOS permissions for HealthKit
- `README.md` - User instructions and setup guide

### Dependencies

- `health: ^13.1.1` - Cross-platform health data integration (Health Connect for Android, HealthKit for iOS)

### Architecture

The app uses a simple StatefulWidget architecture:

1. **MyApp** - Root application widget
2. **StepCounterPage** - Main page that displays the step count with platform detection

### Cross-Platform Health Integration

The app uses the `health` package to:

#### Android (Health Connect):
1. Configure Health Connect support via AndroidManifest.xml
2. Request read permissions for step data
3. Fetch step data for the current day
4. Calculate total steps from all data points

#### iOS (HealthKit):
1. Configure HealthKit support via Info.plist permissions
2. Request read permissions for step data 
3. Fetch step data for the current day
4. Calculate total steps from all data points

### Platform Detection

The app automatically detects the platform using `dart:io Platform.isIOS` and:
- Shows "HealthKit" messages on iOS
- Shows "Health Connect" messages on Android
- Provides platform-specific manual setup instructions
- Adapts button text and debug information accordingly

### Error Handling

The app handles errors gracefully by:

- Displaying 0 if permissions are denied
- Displaying 0 if no step data is available
- Displaying 0 if any error occurs during data fetching
- Platform-specific error messages and troubleshooting steps

### UI Design

- White background as specified in requirements
- Black text displaying the step count
- Large font size (48px) for easy reading
- Loading indicator while fetching data
- Debug information showing current platform (iOS/Android)
- Platform-specific manual setup instructions

## Development Notes

- The app targets both Android devices with Health Connect support and iOS devices with HealthKit
- No simulation of data - only real step data is displayed
- Minimal feature set as requested in the specifications
- Clean code structure for easy maintenance
- Cross-platform compatibility using a single codebase
