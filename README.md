# Simple Step Flutter

A simple Flutter app that displays the step count from Health Connect on Android devices.

## Features

- Displays step count from Health Connect in large black numbers on a white background
- Shows 0 if no step data is available or permissions are denied
- Graceful error handling

## Requirements

- Android device with Health Connect support
- Flutter SDK installed
- Android development environment set up

## Installation & Setup

1. Clone or download this project
2. Open terminal in the project directory
3. Install dependencies:

   ```bash
   flutter pub get
   ```

## How to Launch the Program

### Option 1: Using VS Code

1. Open the project in VS Code
2. Connect your Android device or start an Android emulator
3. Press F5 or go to Run > Start Debugging
4. Select your target device when prompted

### Option 2: Using Command Line

1. Connect your Android device via USB with developer mode enabled, or start an Android emulator
2. Open terminal in the project directory
3. Check connected devices:

   ```bash
   flutter devices
   ```

4. Run the app:

   ```bash
   flutter run
   ```

### Option 3: Build APK for Installation

1. Build the APK:

   ```bash
   flutter build apk --release
   ```

2. Install the APK on your device:

   ```bash
   flutter install
   ```

## Permissions

The app will request permission to read step data from Health Connect when first launched. Grant the permission to see your actual step count.

## Troubleshooting

- If you see "0" steps, make sure Health Connect is installed and has step data
- Ensure you've granted the app permission to read health data
- Make sure your device supports Health Connect (Android 14+ or compatible devices)

## Development

- Built with Flutter and Dart
- Uses the `health` package for Health Connect integration
- Minimal UI focusing on displaying step count only
