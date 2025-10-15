# Firebase Manual Setup - Simple Guide

## 🎯 Goal
Get your Firebase project configured in 10 minutes without CLI tools.

---

## Step 1: Create Firebase Project (5 minutes)

1. **Go to**: https://console.firebase.google.com/
2. **Click**: "Add project" or "Create a project"
3. **Enter name**: `AnchorNoteApp` (or any name you like)
4. **Disable Google Analytics**: Toggle OFF (we don't need it)
5. **Click**: "Create project"
6. **Wait** for project creation (30 seconds)
7. **Click**: "Continue"

---

## Step 2: Add Android App (3 minutes)

1. **In Firebase Console**, you'll see "Get started by adding Firebase to your app"
2. **Click the Android icon** (robot icon)
3. **Fill in**:
   - Android package name: `com.example.anchornotes`
   - App nickname: `SyncPad` (optional)
   - Debug signing certificate: Leave blank for now
4. **Click**: "Register app"
5. **Download** the `google-services.json` file
6. **Save it to**: `C:\anchornotes\android\app\google-services.json`
   - Make sure it's in the `app` folder, not just `android`!
7. **Click**: "Next" → "Next" → "Continue to console"

---

## Step 3: Enable Authentication (2 minutes)

1. **In Firebase Console sidebar**, click "Authentication"
2. **Click**: "Get started"
3. **Go to**: "Sign-in method" tab
4. **Enable Email/Password**:
   - Click "Email/Password"
   - Toggle "Enable" to ON
   - Click "Save"
5. **Enable Google Sign-In**:
   - Click "Google"
   - Toggle "Enable" to ON
   - Select your email as "Project support email"
   - Click "Save"

---

## Step 4: Get Firebase Configuration

1. **In Firebase Console**, click the ⚙️ gear icon → "Project settings"
2. **Scroll down** to "Your apps" section
3. **Click on your Android app** (com.example.anchornotes)
4. **Copy these values** (you'll need them):

```
API Key: AIza...
App ID: 1:123...:android:abc...
Project ID: anchornotea...
Messaging Sender ID: 123...
Storage Bucket: anchornotea....appspot.com
```

---

## Step 5: Update firebase_options.dart

Open `C:\anchornotes\lib\firebase_options.dart` and replace the Android section:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_HERE',              // From step 4
  appId: 'YOUR_APP_ID_HERE',                // From step 4
  messagingSenderId: 'YOUR_SENDER_ID_HERE', // From step 4
  projectId: 'YOUR_PROJECT_ID_HERE',        // From step 4
  storageBucket: 'YOUR_STORAGE_BUCKET_HERE', // From step 4
);
```

**Example** (with fake values):
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  appId: '1:123456789:android:abcdef123456',
  messagingSenderId: '123456789',
  projectId: 'anchornotea-12345',
  storageBucket: 'anchornotea-12345.appspot.com',
);
```

---

## Step 6: Verify Files

Make sure these files exist:

```
✅ C:\anchornotes\android\app\google-services.json
✅ C:\anchornotes\lib\firebase_options.dart (updated with your values)
```

---

## Step 7: Test the App

```bash
cd C:\anchornotes
flutter pub get
flutter run
```

You should see:
1. Login screen appears
2. Can create an account
3. Can sign in with email/password
4. Can logout

---

## 🐛 Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
- Check `google-services.json` is in `android/app/` folder
- Check `firebase_options.dart` has correct values
- Run `flutter clean` then `flutter run`

### Error: "API key not valid"
- Double-check you copied the correct API key from Firebase Console
- Make sure there are no extra spaces

### Google Sign-In doesn't work
- You'll need to add SHA-1 fingerprint (we can do this later)
- For now, just use email/password authentication

---

## ✅ Success Checklist

- [ ] Firebase project created
- [ ] Android app registered in Firebase
- [ ] `google-services.json` downloaded and placed correctly
- [ ] Email/Password authentication enabled
- [ ] Google Sign-In enabled
- [ ] `firebase_options.dart` updated with your values
- [ ] App runs without Firebase errors
- [ ] Can create account and login

---

## 🎉 You're Done!

Once all checkboxes are complete, Phase 2 is fully functional!

**Next**: Phase 3 will add cloud sync with Firestore.
