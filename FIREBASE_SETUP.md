# Firebase Setup Guide for SyncPad

## 📋 Prerequisites
- Flutter project (already set up)
- Google account
- Firebase CLI installed (optional but recommended)

---

## 🔥 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `syncpad` (or your preferred name)
4. Disable Google Analytics (optional for this project)
5. Click **"Create project"**

---

## 📱 Step 2: Add Android App

### 2.1 Register Android App
1. In Firebase Console, click **"Add app"** → Select **Android**
2. Enter Android package name: `com.example.anchornotes`
   - Find this in `android/app/build.gradle.kts` under `applicationId`
3. App nickname: `SyncPad Android` (optional)
4. Click **"Register app"**

### 2.2 Download google-services.json
1. Download the `google-services.json` file
2. Place it in: `android/app/google-services.json`

### 2.3 Configure Android Project
The project is already configured, but verify these files:

**android/build.gradle.kts:**
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

**android/app/build.gradle.kts:**
```kotlin
plugins {
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
}
```

---

## 🍎 Step 3: Add iOS App

### 3.1 Register iOS App
1. In Firebase Console, click **"Add app"** → Select **iOS**
2. Enter iOS bundle ID: `com.example.anchornotes`
   - Find this in `ios/Runner/Info.plist` under `CFBundleIdentifier`
3. App nickname: `SyncPad iOS` (optional)
4. Click **"Register app"**

### 3.2 Download GoogleService-Info.plist
1. Download the `GoogleService-Info.plist` file
2. Open Xcode: `open ios/Runner.xcworkspace`
3. Drag `GoogleService-Info.plist` into the `Runner` folder in Xcode
4. Ensure **"Copy items if needed"** is checked
5. Select `Runner` target

---

## 🌐 Step 4: Add Web App (Optional)

1. In Firebase Console, click **"Add app"** → Select **Web**
2. Enter app nickname: `SyncPad Web`
3. Click **"Register app"**
4. Copy the Firebase configuration
5. You'll use these values in `lib/firebase_options.dart`

---

## 🔐 Step 5: Enable Authentication

### 5.1 Enable Email/Password Authentication
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click **"Email/Password"**
3. Enable **"Email/Password"**
4. Click **"Save"**

### 5.2 Enable Google Sign-In
1. In the same **Sign-in method** tab
2. Click **"Google"**
3. Enable **"Google"**
4. Select a support email
5. Click **"Save"**

### 5.3 Configure OAuth Consent Screen (for Google Sign-In)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services** → **OAuth consent screen**
4. Fill in required fields:
   - App name: `SyncPad`
   - User support email: Your email
   - Developer contact: Your email
5. Click **"Save and Continue"**

---

## ⚙️ Step 6: Configure Firebase Options

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Run configuration:
```bash
flutterfire configure
```

3. Select your Firebase project
4. Select platforms (Android, iOS, Web, Windows)
5. This will automatically generate `lib/firebase_options.dart`

### Option B: Manual Configuration

If you prefer manual setup, update `lib/firebase_options.dart` with your Firebase project values:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',           // From google-services.json
  appId: 'YOUR_ANDROID_APP_ID',             // From google-services.json
  messagingSenderId: 'YOUR_SENDER_ID',      // From google-services.json
  projectId: 'YOUR_PROJECT_ID',             // From Firebase Console
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',               // From GoogleService-Info.plist
  appId: 'YOUR_IOS_APP_ID',                 // From GoogleService-Info.plist
  messagingSenderId: 'YOUR_SENDER_ID',      // From GoogleService-Info.plist
  projectId: 'YOUR_PROJECT_ID',             // From Firebase Console
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  iosBundleId: 'com.example.anchornotes',
);
```

---

## 🔧 Step 7: Configure Google Sign-In for Android

### 7.1 Get SHA-1 Certificate Fingerprint

**For Debug Build:**
```bash
cd android
./gradlew signingReport
```

Look for the **SHA-1** under `Variant: debug` → `Config: debug`

**For Release Build:**
You'll need your keystore file. If you don't have one:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then get SHA-1:
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

### 7.2 Add SHA-1 to Firebase

1. In Firebase Console, go to **Project Settings**
2. Scroll to **Your apps** → Select your Android app
3. Click **"Add fingerprint"**
4. Paste your SHA-1 fingerprint
5. Click **"Save"**
6. Download the updated `google-services.json`
7. Replace the old one in `android/app/`

---

## 🧪 Step 8: Test the Setup

### 8.1 Get Dependencies
```bash
flutter pub get
```

### 8.2 Run the App
```bash
flutter run
```

### 8.3 Test Authentication
1. App should show the login screen
2. Try creating an account with email/password
3. Try signing in with Google
4. Verify you can logout

### 8.4 Verify in Firebase Console
1. Go to **Authentication** → **Users**
2. You should see your test account listed

---

## 🐛 Troubleshooting

### Issue: "Default FirebaseApp is not initialized"
**Solution:** Make sure Firebase is initialized in `main.dart` before `runApp()`

### Issue: Google Sign-In not working on Android
**Solution:** 
1. Verify SHA-1 is added to Firebase
2. Download updated `google-services.json`
3. Clean and rebuild: `flutter clean && flutter run`

### Issue: "PlatformException: sign_in_failed"
**Solution:**
1. Check OAuth consent screen is configured
2. Verify Google Sign-In is enabled in Firebase Console
3. Ensure SHA-1 fingerprint is correct

### Issue: iOS build fails
**Solution:**
1. Verify `GoogleService-Info.plist` is in the correct location
2. Run `pod install` in the `ios` directory
3. Clean build folder in Xcode

### Issue: "FirebaseOptions not configured"
**Solution:** Run `flutterfire configure` or manually update `firebase_options.dart`

---

## 📊 Firebase Console Overview

### Key Sections
- **Authentication**: Manage users and sign-in methods
- **Firestore Database**: Will be used in Phase 3 for sync
- **Storage**: Will be used for file attachments (future)
- **Project Settings**: API keys and app configuration

### Security Rules (Phase 3)
We'll configure Firestore security rules when implementing cloud sync.

---

## 🔒 Security Best Practices

1. **Never commit Firebase config files to public repos**
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - These are already in `.gitignore`

2. **Use environment-specific projects**
   - Development project for testing
   - Production project for release

3. **Enable App Check** (optional, for production)
   - Protects your backend from abuse

4. **Set up Firebase Security Rules**
   - Will be configured in Phase 3

---

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In Setup](https://firebase.google.com/docs/auth/android/google-signin)

---

## ✅ Checklist

Before proceeding, ensure:
- [ ] Firebase project created
- [ ] Android app registered and `google-services.json` added
- [ ] iOS app registered and `GoogleService-Info.plist` added
- [ ] Email/Password authentication enabled
- [ ] Google Sign-In enabled
- [ ] SHA-1 fingerprint added (Android)
- [ ] `firebase_options.dart` configured
- [ ] App runs without errors
- [ ] Can create account and login
- [ ] Can logout successfully

---

**Once all steps are complete, Phase 2 is ready!** 🎉

**Next:** Phase 3 will add Firestore for cloud sync and multi-device support.
