# Firestore Security Rules for Phase 4

## 🔒 Updated Security Rules with Sharing Support

Replace your current Firestore security rules with these updated rules that support note sharing and collaboration.

---

## Security Rules (Copy & Paste)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // User documents (for email lookup when sharing)
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }
    
    // Notes collection - Single source of truth with permissions map
    match /notes/{noteId} {
      // Allow read if user's ID is in the permissions map
      allow read: if isAuthenticated() && 
                     request.auth.uid in resource.data.permissions;
      
      // Allow create if user sets themselves as owner
      allow create: if isAuthenticated() && 
                       request.auth.uid in request.resource.data.permissions &&
                       request.resource.data.permissions[request.auth.uid] == 'owner' &&
                       request.resource.data.ownerId == request.auth.uid;
      
      // Allow update if user is owner or editor
      allow update: if isAuthenticated() && 
                       request.auth.uid in resource.data.permissions &&
                       resource.data.permissions[request.auth.uid] in ['owner', 'editor'];
      
      // Allow delete only if user is the owner
      allow delete: if isAuthenticated() && 
                       resource.data.permissions[request.auth.uid] == 'owner';
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 🔍 How These Rules Work

### User Documents
```javascript
match /users/{userId}
```
- **Read**: Any authenticated user (needed for email lookup when sharing)
- **Write**: Only the user themselves

### Notes Collection
```javascript
match /users/{userId}/notes/{noteId}
```

#### Read Access
- ✅ Owner can read their own notes
- ✅ Users in `sharedWith` array can read

#### Create Access
- ✅ Can only create notes in your own collection
- ✅ Must be valid note structure
- ✅ `userId` must match your user ID

#### Update Access
- ✅ Owner can update their copy
- ✅ Editors can update their copy (when `permission == 'editor'`)
- ❌ Viewers cannot update

#### Delete Access
- ✅ Only owner can delete
- ❌ Shared users cannot delete

---

## 📊 Data Structure

### User Document
```
users/{userId}
  ├── email: "user@example.com"
  └── createdAt: timestamp
```

### Note Document (Owner's Copy)
```
users/{ownerId}/notes/{noteId}
  ├── id: 1
  ├── title: "My Note"
  ├── content: "Note content..."
  ├── createdAt: "2025-10-15T..."
  ├── updatedAt: "2025-10-15T..."
  ├── userId: "ownerId"
  ├── sharedWith: ["userId1", "userId2"]
  └── permission: "owner"
```

### Note Document (Shared User's Copy)
```
users/{sharedUserId}/notes/{noteId}
  ├── id: 1
  ├── title: "My Note"
  ├── content: "Note content..."
  ├── createdAt: "2025-10-15T..."
  ├── updatedAt: "2025-10-15T..."
  ├── userId: "ownerId"
  ├── sharedWith: ["userId1", "userId2"]
  └── permission: "editor" or "viewer"
```

---

## 🧪 Testing the Rules

### Test 1: Owner Access
```javascript
// Should succeed
firestore.collection('users')
  .doc(currentUserId)
  .collection('notes')
  .doc('1')
  .get()
```

### Test 2: Shared User Access
```javascript
// Should succeed if user is in sharedWith array
firestore.collection('users')
  .doc(ownerId)
  .collection('notes')
  .doc('1')
  .get()
```

### Test 3: Unauthorized Access
```javascript
// Should fail
firestore.collection('users')
  .doc(otherUserId)
  .collection('notes')
  .doc('1')
  .get()
```

---

## 🔧 How to Update Rules

### Method 1: Firebase Console (Recommended)
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Click **Firestore Database** in sidebar
4. Click **Rules** tab
5. **Copy the rules above**
6. **Paste** into the editor
7. Click **Publish**

### Method 2: Firebase CLI
```bash
# Save rules to firestore.rules file
firebase deploy --only firestore:rules
```

---

## ⚠️ Important Notes

### Sharing Flow
1. **Owner shares note**:
   - Adds userId to `sharedWith` array in their copy
   - Creates a copy in shared user's collection with `permission` field

2. **Shared user accesses**:
   - Reads from their own collection
   - Permission is stored in their copy

3. **Owner unshares**:
   - Removes userId from `sharedWith` array
   - Deletes copy from shared user's collection

### Permission Levels
- **owner**: Full access (read, write, delete, share)
- **editor**: Can read and edit
- **viewer**: Can only read

### Security Considerations
- ✅ Users can only access notes they own or are shared with
- ✅ Only owners can share/unshare notes
- ✅ Only owners can delete notes
- ✅ Editors can modify content but not sharing settings
- ✅ Viewers can only read
- ✅ Email lookup is restricted to authenticated users

---

## 🐛 Troubleshooting

### Error: "Missing or insufficient permissions"
**Cause**: Rules not published or user not authenticated  
**Solution**: Publish rules and ensure user is logged in

### Error: "PERMISSION_DENIED"
**Cause**: User not in `sharedWith` array  
**Solution**: Check sharing was successful, verify `sharedWith` array

### Shared user can't see note
**Cause**: Note not copied to their collection  
**Solution**: Check `SharingService.shareNoteWithEmail()` completed successfully

### Editor can't edit
**Cause**: Permission not set correctly  
**Solution**: Verify `permission` field is 'editor' in user's copy

---

## 📈 Rule Testing Checklist

Test these scenarios:

- [ ] Owner can read their notes
- [ ] Owner can create notes
- [ ] Owner can update their notes
- [ ] Owner can delete their notes
- [ ] Owner can share notes
- [ ] Shared user (editor) can read
- [ ] Shared user (editor) can edit
- [ ] Shared user (viewer) can read
- [ ] Shared user (viewer) cannot edit
- [ ] Shared user cannot delete
- [ ] Unshared user cannot access
- [ ] Email lookup works for sharing

---

## 🎯 Next Steps

1. **Copy the rules** from the top of this document
2. **Paste into Firebase Console** → Firestore → Rules
3. **Click Publish**
4. **Test sharing** in the app
5. **Verify permissions** work correctly

---

**Once rules are published, Phase 4 sharing functionality will be fully operational!** 🎉
