# 🎨 App Icon & Splash Screen Setup Guide

## Overview

This guide will help you set up the app icon and splash screen for AnchorNotes.

---

## 📱 App Icon Setup

### Step 1: Create App Icon

**Design Requirements**:
- Size: 1024x1024 pixels (will be scaled down)
- Format: PNG with transparency
- Design: Simple, recognizable, works at small sizes

**Design Concept for AnchorNotes**:
```
Icon Idea: 
- A stylized anchor (⚓) combined with a note/document
- Colors: Primary blue (#2196F3) with accent orange (#FF9800)
- Clean, modern, Material Design style
```

**Tools to Create Icon**:
1. **Figma** (free, online)
2. **Canva** (free templates)
3. **Adobe Illustrator** (professional)
4. **Icon generators**: https://icon.kitchen/

### Step 2: Install flutter_launcher_icons Package

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#2196F3"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

### Step 3: Add Icon Files

Create directory structure:
```
assets/
  icon/
    app_icon.png          # 1024x1024 main icon
    app_icon_foreground.png  # 1024x1024 foreground (Android adaptive)
```

### Step 4: Generate Icons

Run command:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for Android and iOS.

---

## 🌟 Splash Screen Setup

### Step 1: Install flutter_native_splash Package

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_native_splash: ^2.3.10

flutter_native_splash:
  color: "#2196F3"
  image: assets/splash/splash_icon.png
  android: true
  ios: true
  
  android_12:
    image: assets/splash/splash_icon.png
    color: "#2196F3"
    
  web: false
```

### Step 2: Create Splash Icon

**Design Requirements**:
- Size: 1152x1152 pixels
- Format: PNG with transparency
- Design: Simplified version of app icon
- Should work on both light and dark backgrounds

**Splash Screen Concept**:
```
Design:
- Centered app icon
- Solid background color (primary blue)
- Optional: App name below icon
- Clean, minimal
```

### Step 3: Add Splash Files

Create directory:
```
assets/
  splash/
    splash_icon.png       # 1152x1152 splash icon
```

### Step 4: Generate Splash Screen

Run command:
```bash
flutter pub get
flutter pub run flutter_native_splash:create
```

---

## 🎨 Quick Setup (Using Placeholder)

If you want to test immediately without custom design:

### 1. Create Simple Icon with Text

Use this Flutter code to generate a simple icon:

```dart
// tools/generate_icon.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create a simple icon
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(1024, 1024);
  
  // Background
  final paint = Paint()..color = Color(0xFF2196F3);
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  
  // Draw anchor symbol or "AN" text
  final textPainter = TextPainter(
    text: TextSpan(
      text: '📝',
      style: TextStyle(fontSize: 512, color: Colors.white),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(256, 256));
  
  // Convert to image and save
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  
  // Save to file
  await Directory('assets/icon').create(recursive: true);
  await File('assets/icon/app_icon.png').writeAsBytes(bytes);
  
  print('Icon generated!');
}
```

### 2. Or Use Online Generator

**Recommended**: https://icon.kitchen/
1. Upload a simple design or use text
2. Choose "Material Design" style
3. Download the generated icons
4. Place in `assets/icon/` folder

---

## 📋 Complete Setup Checklist

### App Icon
- [ ] Create 1024x1024 app icon design
- [ ] Add `flutter_launcher_icons` to `pubspec.yaml`
- [ ] Place icon in `assets/icon/app_icon.png`
- [ ] Run `flutter pub run flutter_launcher_icons`
- [ ] Test on Android device
- [ ] Test on iOS device (if applicable)

### Splash Screen
- [ ] Create 1152x1152 splash icon
- [ ] Add `flutter_native_splash` to `pubspec.yaml`
- [ ] Place splash icon in `assets/splash/splash_icon.png`
- [ ] Run `flutter pub run flutter_native_splash:create`
- [ ] Test app launch on Android
- [ ] Test app launch on iOS (if applicable)

### Verification
- [ ] App icon appears on home screen
- [ ] Splash screen shows on app launch
- [ ] Colors match app theme
- [ ] Icon is recognizable at small sizes
- [ ] No pixelation or distortion

---

## 🎨 Design Guidelines

### App Icon Best Practices

1. **Keep it Simple**: Icon should be recognizable at 48x48 pixels
2. **Use Brand Colors**: Primary blue (#2196F3) and accent orange (#FF9800)
3. **Avoid Text**: Small text is hard to read at icon sizes
4. **Test on Dark/Light**: Ensure visibility on both backgrounds
5. **Unique Shape**: Stand out from other apps

### Splash Screen Best Practices

1. **Match App Theme**: Use same colors as app
2. **Quick Loading**: Keep it simple for fast display
3. **Center Icon**: Standard placement
4. **Solid Background**: Avoid gradients for consistency
5. **No Animation**: Native splash is static

---

## 🚀 Quick Start Commands

```bash
# 1. Add packages to pubspec.yaml (see above)

# 2. Get packages
flutter pub get

# 3. Generate app icon
flutter pub run flutter_launcher_icons

# 4. Generate splash screen
flutter pub run flutter_native_splash:create

# 5. Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 📱 Platform-Specific Notes

### Android

**Icon Sizes Generated**:
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

**Adaptive Icon** (Android 8.0+):
- Foreground layer (with transparency)
- Background layer (solid color)
- System applies shape mask

### iOS

**Icon Sizes Generated**:
- 20x20 to 1024x1024 (all required sizes)
- Automatically added to Assets.xcassets

**Requirements**:
- No transparency (iOS requirement)
- No alpha channel
- Square shape

---

## 🎨 Temporary Solution

Until you create custom icons, the app will use default Flutter icons. This is fine for development but should be updated before production release.

**Priority**: Medium (can be done anytime before Play Store submission)

---

## 📚 Resources

- **Icon Design**: https://icon.kitchen/
- **Color Palette**: https://materialpalette.com/
- **Icon Guidelines**: https://m3.material.io/styles/icons/
- **Flutter Icons Package**: https://pub.dev/packages/flutter_launcher_icons
- **Splash Package**: https://pub.dev/packages/flutter_native_splash

---

**Status**: Setup guide complete ✅  
**Next Step**: Create icon design and run generation commands

---

**Last Updated**: October 16, 2025
