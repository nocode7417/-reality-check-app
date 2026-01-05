# Reality Check - Flutter App

A Gen-Z focused productivity app that helps you understand where your time is being wasted and what that time could have realistically produced.

## 🎯 Features

- **Time Tracking**: Manual activity logging with app/category selection
- **Reality-Check Stats**: See potential earnings and learning progress from wasted time
- **Color-Intensity Calendar**: Monthly heatmap visualization of time patterns
- **Beautiful iOS-Style UI**: Premium design with micro-animations

## 📱 Screenshots

| Dashboard | Calendar | Logger |
|-----------|----------|--------|
| Weekly stats, earnings potential, trend chart | Monthly heatmap, progress ring | App selection, duration picker |

## 🛠 Tech Stack

- **Flutter 3.x** - Cross-platform UI framework
- **Riverpod** - State management
- **GoRouter** - Declarative navigation
- **Hive** - Local database (offline-first)
- **FL Chart** - Data visualization
- **Custom Painters** - iOS-style icons

## 🚀 Getting Started

### Prerequisites

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+)
2. Install [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/)
3. Set up device/emulator

### Installation

```bash
# Clone and navigate
cd flutter_app

# Install dependencies
flutter pub get

# Generate code (Hive adapters, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run
```

## 📦 Build for Release

### Android APK

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA

```bash
# Build for iOS
flutter build ios --release

# Then open Xcode
open ios/Runner.xcworkspace

# Archive and export from Xcode
# Product > Archive > Distribute App
```

## 🔐 Signing Configuration

### Android

1. Create keystore:
```bash
keytool -genkey -v -keystore ~/reality-check.jks -keyalg RSA -keysize 2048 -validity 10000 -alias reality-check
```

2. Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=reality-check
storeFile=/path/to/reality-check.jks
```

3. Update `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### iOS

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Runner target > Signing & Capabilities
3. Select your Team and enable automatic signing
4. Set Bundle Identifier to your app ID

## 📲 Install APK on Device

```bash
# List connected devices
adb devices

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or install with flutter
flutter install --release
```

## 🏗 Project Structure

```
lib/
├── core/
│   ├── theme/           # Colors, typography, spacing, animations
│   ├── constants/       # App constants
│   └── utils/           # Utilities
├── data/
│   ├── models/          # Data models (Activity, Settings, etc.)
│   ├── repositories/    # Data repositories
│   └── services/        # Storage, Analytics, Calculations
├── domain/
│   ├── entities/        # Business entities
│   └── usecases/        # Use cases
├── presentation/
│   ├── providers/       # Riverpod providers
│   ├── navigation/      # GoRouter config
│   ├── screens/         # Screen widgets
│   │   ├── dashboard/
│   │   ├── calendar/
│   │   └── logger/
│   └── widgets/         # Reusable widgets
│       └── common/
└── main.dart            # App entry point
```

## 📊 Analytics Event Schema

| Event | Properties | Description |
|-------|------------|-------------|
| `session_start` | - | App opened |
| `session_end` | duration_seconds, screen_views | App closed |
| `screen_view` | screen_name | Screen viewed |
| `activity_logged` | category, duration_bucket, is_productive | Activity saved |
| `calendar_day_selected` | has_data | Calendar day tapped |
| `calendar_navigation` | direction | Month changed |

## ✅ QA Checklist

### Functionality
- [ ] Activity logging saves correctly
- [ ] Stats calculations are accurate
- [ ] Calendar displays correct data
- [ ] Navigation works between all screens
- [ ] Animations are smooth (60fps)

### UI/UX
- [ ] Colors match design system
- [ ] Typography is consistent
- [ ] Spacing follows 4px grid
- [ ] Icons render correctly
- [ ] Safe area insets respected

### Performance
- [ ] App starts in < 2 seconds
- [ ] No jank during scrolling
- [ ] Memory usage stable
- [ ] Battery efficient

### Edge Cases
- [ ] Empty state displays
- [ ] Future dates disabled
- [ ] Long text truncates
- [ ] Works offline

## 🔧 Performance Optimization

```dart
// Profile mode for performance testing
flutter run --profile

// Analyze app size
flutter build apk --analyze-size

// Check for widget rebuilds
flutter run --profile --track-widget-creation
```

## 📄 License

MIT License - See LICENSE file

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request




