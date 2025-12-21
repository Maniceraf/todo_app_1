# 📦 Flutter APK Build Guide - Task Manager

## 🚀 Quick Build Commands

### 1. Build Optimized APK (Split per ABI - Recommended)
```bash
flutter build apk --split-per-abi --release
```
**Output:** 3 APK files (~15-20MB each)
- `app-armeabi-v7a-release.apk` (32-bit ARM devices)
- `app-arm64-v8a-release.apk` (64-bit ARM devices) ⭐ Most common
- `app-x86_64-release.apk` (x86 devices)

**Location:** `build/app/outputs/flutter-apk/`

### 2. Build Universal APK (Single file)
```bash
flutter build apk --release
```
**Output:** `app-release.apk` (~45MB)
**Use case:** Testing, quick distribution

### 3. Build App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```
**Output:** `app-release.aab` (~25-30MB)
**Location:** `build/app/outputs/bundle/release/`

---

## 🔧 Advanced Build Commands

### With Code Shrinking & Obfuscation
```bash
flutter build apk --split-per-abi --release --shrink --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Analyze APK Size
```bash
flutter build apk --analyze-size
```

### Build for Specific ABI only
```bash
# 64-bit ARM only (most devices)
flutter build apk --target-platform android-arm64 --release
```

---

## ⚙️ Pre-Build Checklist

### 1. Clean Build
```bash
flutter clean
flutter pub get
```

### 2. Check Dependencies
```bash
flutter pub deps
flutter doctor -v
```

### 3. Test Release Build Locally
```bash
# Install on connected device
flutter install --release

# Or build and install
flutter build apk --split-per-abi --release
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## 📊 Size Optimization Applied

| Optimization | Status | Size Reduction |
|--------------|--------|----------------|
| ProGuard/R8 enabled | ✅ | ~20-30% |
| Split per ABI | ✅ | ~30-40% |
| Local fonts (removed google_fonts) | ✅ | ~7-10MB |
| Shrink resources | ✅ | ~5-10% |

### Configuration Files:
- **ProGuard rules:** `android/app/proguard-rules.pro`
- **Build config:** `android/app/build.gradle`
  ```gradle
  release {
      minifyEnabled true
      shrinkResources true
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
  }
  ```

---

## 🔐 Signing Configuration (Production)

### 1. Create Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configure Signing (android/key.properties)
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

### 3. Update build.gradle
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
    }
}
```

---

## 📱 Testing APK

### Install via ADB
```bash
# List connected devices
adb devices

# Install APK
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Uninstall
adb uninstall com.example.task_manager
```

### Check APK Size
```bash
# Windows PowerShell
Get-ChildItem build/app/outputs/flutter-apk/*.apk | Select-Object Name, @{Name="Size(MB)";Expression={[math]::Round($_.Length/1MB,2)}}

# Linux/Mac
ls -lh build/app/outputs/flutter-apk/*.apk
```

---

## 🐛 Troubleshooting

### Build Fails with ProGuard
```bash
# Disable temporarily to test
# In android/app/build.gradle, set:
minifyEnabled false
```

### Font Not Found Error
```bash
# Check pubspec.yaml fonts section
# Verify font files exist in assets/fonts/
flutter clean
flutter pub get
```

### APK Too Large
1. Check for unused assets: `flutter analyze`
2. Remove unused packages: `flutter pub deps`
3. Compress images with TinyPNG
4. Use WebP instead of PNG

---

## 📈 Expected APK Sizes

| Build Type | Size Range | Notes |
|------------|------------|-------|
| Debug APK | ~60-80MB | With debug symbols |
| Release APK (universal) | ~45MB | Single APK for all devices |
| Release APK (split per ABI) | ~15-20MB | Per architecture |
| App Bundle (.aab) | ~25-30MB | For Play Store |

---

## 🚢 Distribution

### Google Play Store
1. Build App Bundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Complete store listing
4. Submit for review

### Direct Distribution
1. Build split APKs: `flutter build apk --split-per-abi --release`
2. Distribute arm64-v8a APK (most common)
3. Users enable "Unknown sources" to install
4. Share via Drive, Firebase, etc.

---

## 📝 Version Management

### Update Version in pubspec.yaml
```yaml
version: 1.0.0+1  # version_name+build_number
```

### Build with Custom Version
```bash
flutter build apk --build-name=1.0.1 --build-number=2
```

---

## ✅ Production Build Checklist

- [ ] Update version number in `pubspec.yaml`
- [ ] Test on real device (not emulator)
- [ ] Run `flutter clean && flutter pub get`
- [ ] Verify all features work in release mode
- [ ] Check APK size is reasonable
- [ ] Test on different Android versions
- [ ] Verify ProGuard doesn't break app
- [ ] Update CHANGELOG.md
- [ ] Tag release in Git: `git tag v1.0.0`
- [ ] Build final APK: `flutter build apk --split-per-abi --release`

---

## 📞 Support

For issues:
1. Check `flutter doctor`
2. Clean and rebuild: `flutter clean && flutter pub get`
3. Check logs: `flutter logs`
4. Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

**Last Updated:** December 2025
**Flutter Version:** 3.5.1
**Target SDK:** Android 13 (API 33)

