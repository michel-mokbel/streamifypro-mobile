# Streamify Pro - Setup & Build Guide

This document provides step-by-step instructions for setting up, configuring, and running the Streamify Pro Flutter application.



## Environment Variables

Streamify Pro uses compile-time environment variables for configuration:

### Available Variables

| Variable | Description | Default Value | Required |
|----------|-------------|---------------|----------|
| `API_BASE_URL` | Base URL for the backend API | `http://localhost/streamifyPro` | Yes |
| `PRODUCTION` | Enable production mode (boolean) | `false` | No |

### Configuration File

Environment variables are defined in `lib/config/environment.dart`:

```dart
class Environment {
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://streamifypro.me/streamifyPro ',
  );
}
```

---

## Installation

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd streamifypro
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate localization files** :
   ```bash
   flutter gen-l10n
   ```

--

## Running Locally

### Development Mode (Default)

Run the app without setting environment variables (uses default values):

```bash
flutter run
```

### Development Mode with Custom API URL

Set the API base URL for local development:

**Linux/macOS:**
```bash
flutter run --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro 
```

**Windows (PowerShell):**
```powershell
flutter run --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro 
```

**Windows (Command Prompt):**
```cmd
flutter run --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro 
```

### Running on Specific Devices

**Run on a connected device:**
```bash
flutter devices                    # List available devices
flutter run -d <device-id>         # Run on specific device
```

**Run on Android emulator:**
```bash
flutter run                        # Auto-selects emulator if running
```

**Run on iOS simulator (macOS only):**
```bash
flutter run                        # Auto-selects simulator if running
```

### Example: Running with Production API

```bash
flutter run --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro  --dart-define=PRODUCTION=true
```

---

## Environment Variable Examples

### Production

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro  --dart-define=PRODUCTION=true
```

---

## Building for Production

### Android

**APK (for testing):**
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro  --dart-define=PRODUCTION=true
```

**App Bundle (for Play Store):**
```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro  --dart-define=PRODUCTION=true
```

**Output locations:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)

**Build for iOS Simulator:**
```bash
flutter build ios --simulator --release --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro --dart-define=PRODUCTION=true
```

**Build for iOS Device:**
```bash
flutter build ios --release --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro  --dart-define=PRODUCTION=true
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload to App Store.

---

## Quick Reference

### Essential Commands

```bash
# Install dependencies
flutter pub get

# Run in debug mode (Desktop/Web)
flutter run

# Run on Android Emulator (with local backend)
flutter run --dart-define=API_BASE_URL=http://localhost/streamifyPro

# Run on Physical Android Device (with local backend)
flutter run --dart-define=API_BASE_URL=http://YOUR_IP_ADDRESS/streamifyPro

# Run with custom API URL
flutter run --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro 

# Build release APK
flutter build apk --release --dart-define=API_BASE_URL=https://streamifypro.me/streamifyPro 

# Check for issues
flutter doctor

# Clean build files
flutter clean

# Update dependencies
flutter pub upgrade
```


**Last Updated:** 2025
