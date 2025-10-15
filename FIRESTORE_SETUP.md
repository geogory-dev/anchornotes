# Firestore Setup Guide for Phase 3

## 🎯 Goal
Enable Cloud Firestore to sync notes across devices in real-time.

---

## Step 1: Enable Cloud Firestore

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: "AnchorNote"
3. **Click "Firestore Database"** in the left sidebar
4. **Click "Create database"**
5. **Select mode**:
   - Choose **"Start in test mode"** (for development)
   - We'll add security rules later
6. **Select location**:
   - Choose closest to your users (e.g., `us-central1`, `asia-southeast1`)
   - **Note**: Cannot be changed later!
7. **Click "Enable"**
8. Wait for Firestore to be created (~30 seconds)

---

## Step 2: Set Up Security Rules

### For Development (Test Mode)
The default test mode rules allow read/write for 30 days. Replace with these rules:

1. **Go to "Rules" tab** in Firestore
2. **Replace with**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User can only access their own notes
    match /users/{userId}/notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. **Click "Publish"**

### Security Rules Explanation:
- ✅ Users can only read/write their own notes
- ✅ Must be authenticated to access data
- ✅ Each user's notes are isolated in their own subcollection
- ❌ No access to other users' data
- ❌ No anonymous access

---

## Step 3: Firestore Data Structure

Your notes will be stored like this:

```
firestore
└── users (collection)
    └── {userId} (document)
        └── notes (subcollection)
            ├── 1 (document)
            │   ├── id: 1
            │   ├── title: "My Note"
            │   ├── content: "Note content..."
            │   ├── createdAt: "2025-10-15T12:00:00Z"
            │   ├── updatedAt: "2025-10-15T12:30:00Z"
            │   └── userId: "abc123..."
            ├── 2 (document)
            └── ...
```

**Benefits of this structure:**
- Each user's data is isolated
- Easy to implement security rules
- Scales well with many users
- Supports real-time sync per user

---

## Step 4: Test Firestore Connection

### Run the app:
```bash
flutter pub get
flutter run
```

### Test sync:
1. **Login** to the app
2. **Open note editor**
3. **Type something**
4. **Wait 2 seconds** (auto-save triggers)
5. **Check Firebase Console** → Firestore Database
6. You should see:
   - `users` collection
   - Your user ID document
   - `notes` subcollection
   - Your note document

---

## Step 5: Test Real-Time Sync

### Single Device Test:
1. **Open note editor**
2. **Type something**
3. **Go to Firebase Console** → Firestore
4. **Find your note** and edit it directly in console
5. **Go back to app** - changes should appear automatically!

### Multi-Device Test (Best way to test sync):
1. **Install app on two devices** (or use emulator + physical device)
2. **Login with same account** on both devices
3. **Edit note on Device 1**
4. **Watch Device 2** - changes appear in real-time!

---

## Step 6: Monitor Sync Status

The app shows sync status in the note editor:

| Icon | Status | Meaning |
|------|--------|---------|
| ☁️ (cloud_queue) | Pending | Waiting to sync |
| ☁️✓ (cloud_done) | Synced | Successfully synced |
| ☁️⚠️ (cloud_off) | Offline | No internet or sync error |
| ⟳ | Saving | Currently saving locally |

---

## 🐛 Troubleshooting

### Error: "Missing or insufficient permissions"
**Solution:** 
- Check security rules are published
- Make sure you're logged in
- Verify userId matches in Firestore path

### Error: "PERMISSION_DENIED"
**Solution:**
- Security rules might be too restrictive
- Check if user is authenticated
- Verify the document path matches security rules

### Notes not syncing
**Solution:**
1. Check internet connection
2. Look at sync status indicator
3. Check Firebase Console for errors
4. Look at Flutter logs: `flutter logs`

### Sync conflicts
**Solution:**
- App uses "Last Write Wins" strategy
- The most recent change (by timestamp) wins
- Both devices will eventually show the same content

---

## 📊 Firestore Quotas (Free Tier)

| Resource | Free Tier Limit |
|----------|----------------|
| Stored data | 1 GB |
| Document reads | 50,000/day |
| Document writes | 20,000/day |
| Document deletes | 20,000/day |
| Network egress | 10 GB/month |

**For SyncPad usage:**
- Each note save = 1 write
- Each note load = 1 read
- Real-time listeners = ongoing reads
- Should be plenty for personal use!

---

## 🔒 Production Security Rules (Future)

For production, add more robust rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isValidNote() {
      return request.resource.data.keys().hasAll(['id', 'title', 'content', 'createdAt', 'updatedAt', 'userId'])
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.title is string
        && request.resource.data.content is string;
    }
    
    // User notes
    match /users/{userId}/notes/{noteId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId) && isValidNote();
      allow update: if isOwner(userId) && isValidNote();
      allow delete: if isOwner(userId);
    }
    
    // Deny everything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## ✅ Firestore Setup Checklist

- [ ] Firestore database created
- [ ] Security rules configured
- [ ] Rules published
- [ ] App can connect to Firestore
- [ ] Notes appear in Firebase Console
- [ ] Real-time sync works
- [ ] Sync status indicator shows correct state
- [ ] Multi-device sync tested (optional)

---

## 🎉 Success!

Once all steps are complete, you have:
- ✅ Real-time cloud sync
- ✅ Offline-first architecture
- ✅ Secure per-user data isolation
- ✅ Automatic conflict resolution
- ✅ Multi-device support

**Next**: Phase 4 will add multi-note management and notes list UI!
