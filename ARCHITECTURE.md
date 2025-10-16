# 🏗️ AnchorNotes Architecture

Comprehensive technical documentation for the AnchorNotes application.

---

## Table of Contents
1. [Overview](#overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Data Layer](#data-layer)
4. [Service Layer](#service-layer)
5. [Presentation Layer](#presentation-layer)
6. [Sync Strategy](#sync-strategy)
7. [Security Model](#security-model)
8. [Performance Considerations](#performance-considerations)

---

## Overview

AnchorNotes is built using a **service-oriented architecture** with **offline-first** principles. The app prioritizes local data access and syncs changes to the cloud when connectivity is available.

### Key Architectural Decisions

1. **Single Source of Truth** - Each note exists once in Firestore with a permissions map
2. **Offline-First** - Local Isar database is the primary data source
3. **Last Write Wins** - Conflict resolution based on timestamps
4. **Service Layer** - Business logic separated from UI
5. **Reactive UI** - StreamBuilder and ValueNotifier for state management

---

## Architecture Pattern

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│  (Screens, Widgets, UI Components)              │
└────────────────┬────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────┐
│              Service Layer                       │
│  (Business Logic, Data Operations)              │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │   Auth   │  │   Sync   │  │ Sharing  │     │
│  │ Service  │  │ Service  │  │ Service  │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└────────────────┬────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────┐
│              Data Layer                          │
│                                                  │
│  ┌──────────────┐         ┌─────────────────┐  │
│  │     Isar     │         │   Firestore     │  │
│  │   (Local)    │  ←────→ │    (Cloud)      │  │
│  └──────────────┘         └─────────────────┘  │
└─────────────────────────────────────────────────┘
```

---

## Data Layer

### Isar Database (Local)

**Purpose**: Fast, offline-first local storage

**Schema**:
```dart
@collection
class Note {
  Id id = Isar.autoIncrement;           // Local ID
  @Index(unique: true, replace: true)
  String? serverId;                      // Firestore document ID
  String title = '';
  String content = '';
  @Index()
  late DateTime createdAt;
  @Index()
  late DateTime updatedAt;
  String ownerId = '';                   // Creator's user ID
  String permission = 'owner';           // Current user's permission
  String syncStatus = 'pending';         // pending, synced, error
  DateTime? lastSyncedAt;
}
```

**Key Features**:
- **Auto-increment local ID** - Fast local operations
- **Unique serverId index** - Quick lookups by Firestore ID
- **Indexed timestamps** - Efficient sorting
- **Sync status tracking** - Know what needs syncing

### Firestore (Cloud)

**Purpose**: Single source of truth, real-time sync

**Structure**:
```javascript
notes/{noteId}
  - title: string
  - content: string
  - ownerId: string
  - permissions: {
      "userId1": "owner",
      "userId2": "editor",
      "userId3": "viewer"
    }
  - createdAt: timestamp
  - updatedAt: timestamp

users/{userId}
  - email: string
  - createdAt: timestamp
```

**Why This Structure?**:
- **Single document per note** - No duplicates, no sync conflicts
- **Permissions map** - Flexible, scalable access control
- **Flat structure** - Better query performance
- **Indexed fields** - Fast queries by user permission

---

## Service Layer

### AuthService

**Responsibilities**:
- User authentication (email/password, Google)
- Session management
- User profile storage
- Data isolation between accounts

**Key Methods**:
```dart
Future<User?> signUpWithEmail({email, password})
Future<User?> signInWithEmail({email, password})
Future<User?> signInWithGoogle()
Future<void> signOut()  // Clears local data
```

**Clean Slate Enforcement**:
- Before any sign-in/sign-up, checks for existing user
- If found, signs out first (clearing local data)
- Ensures no data leakage between accounts

### IsarService

**Responsibilities**:
- Local CRUD operations
- Query and search
- Data persistence

**Key Methods**:
```dart
Future<int> createNote(Note note)
Future<Note?> getNote(int id)
Future<Note?> getNoteByServerId(String serverId)
Future<int> updateNote(Note note)
Future<void> deleteNote(int id)
Future<bool> deleteNoteByServerId(String serverId)
Future<List<Note>> getAllNotes()
Stream<List<Note>> watchAllNotes()
Future<List<Note>> searchNotes(String query)
```

**Performance Optimizations**:
- Indexed queries for fast lookups
- Stream-based updates for reactive UI
- Batch operations where possible

### SyncService

**Responsibilities**:
- Bidirectional sync between Isar and Firestore
- Conflict resolution
- Real-time listener management
- Error handling and retry

**Key Methods**:
```dart
Future<void> initialize()
Future<void> pushNote(Note note)
Future<void> syncAll()
Future<void> deleteNote(int noteId)
Future<void> retryFailedSyncs()
String getErrorMessage(dynamic error)
```

**Sync Flow**:

1. **Push (Local → Cloud)**:
```
Note modified locally
  ↓
Mark as 'pending'
  ↓
Push to Firestore
  ↓
Update serverId if new
  ↓
Mark as 'synced'
```

2. **Pull (Cloud → Local)**:
```
Firestore listener triggers
  ↓
Get remote note
  ↓
Find local note by serverId
  ↓
Compare timestamps
  ↓
Last Write Wins
  ↓
Update local or remote
```

**Conflict Resolution**:
```dart
if (remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
  // Remote is newer → Update local
  await updateLocalNote(remoteNote);
} else if (remoteNote.updatedAt.isBefore(localNote.updatedAt)) {
  // Local is newer → Push to remote
  await pushNote(localNote);
} else {
  // Timestamps match → Check permission changes
  if (remoteNote.permission != localNote.permission) {
    await updateLocalPermission(remoteNote.permission);
  }
}
```

### SharingService

**Responsibilities**:
- Share notes with users
- Manage collaborators
- Update permissions
- Email lookup

**Key Methods**:
```dart
Future<void> shareNoteWithEmail({note, email, permission})
Future<void> unshareNote({note, userId})
Future<void> updatePermission({note, userId, newPermission})
Future<List<Map<String, dynamic>>> getCollaborators(Note note)
```

**Sharing Flow**:
```
Owner shares note
  ↓
Look up user by email
  ↓
Update permissions map: permissions.{userId} = 'editor'
  ↓
Firestore triggers listener on shared user's device
  ↓
Note appears in shared user's list
```

---

## Presentation Layer

### Screen Hierarchy

```
MaterialApp
  └── AuthGate (StreamBuilder on auth state)
      ├── AuthScreen (if not authenticated)
      └── HomeScreen (if authenticated)
          └── NotesListScreen
              └── NoteEditorScreen
                  └── SharingDialog
```

### State Management

**ValueNotifier** for simple state:
```dart
final ValueNotifier<String> _syncStatus = ValueNotifier('idle');
```

**StreamBuilder** for reactive data:
```dart
StreamBuilder<List<Note>>(
  stream: _isarService.watchAllNotes(),
  builder: (context, snapshot) {
    // Rebuild when notes change
  },
)
```

### Navigation

- **Hero Animations** - Smooth card-to-editor transitions
- **PageRouteBuilder** - Custom slide + fade transitions
- **Navigator 2.0** - Could be added for deep linking

---

## Sync Strategy

### Offline-First Principles

1. **Local First**: All operations happen on local database first
2. **Background Sync**: Changes sync to cloud asynchronously
3. **Optimistic UI**: UI updates immediately, sync happens in background
4. **Graceful Degradation**: App works fully offline

### Real-Time Listener

```dart
_firestore
  .collection('notes')
  .where('permissions.${userId}', isNotEqualTo: null)
  .snapshots()
  .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          handleRemoteNoteUpdate(change.doc);
          break;
        case DocumentChangeType.removed:
          handleRemoteNoteDelete(change.doc.id);
          break;
      }
    }
  });
```

### Permission Revocation

When a user is removed from permissions:
1. Firestore query no longer matches for that user
2. `DocumentChangeType.removed` event is sent
3. Local note is deleted via `deleteNoteByServerId()`
4. Note disappears from UI
5. Cleanup also runs to catch any orphaned notes

---

## Security Model

### Firestore Security Rules

```javascript
// Read: User must be in permissions map
allow read: if request.auth.uid in resource.data.permissions;

// Create: User sets themselves as owner
allow create: if request.auth.uid == request.resource.data.ownerId &&
                 request.resource.data.permissions[request.auth.uid] == 'owner';

// Update: User must be owner or editor
allow update: if request.auth.uid in resource.data.permissions &&
                 resource.data.permissions[request.auth.uid] in ['owner', 'editor'];

// Delete: Only owner can delete
allow delete: if resource.data.permissions[request.auth.uid] == 'owner';
```

### Permission Levels

| Level  | Read | Write | Share | Delete |
|--------|------|-------|-------|--------|
| Owner  | ✅   | ✅    | ✅    | ✅     |
| Editor | ✅   | ✅    | ❌    | ❌     |
| Viewer | ✅   | ❌    | ❌    | ❌     |

### Data Isolation

- Each user's local Isar database is cleared on sign-out
- Sign-in/sign-up enforces clean slate
- Firestore queries filter by user permissions
- No cross-account data leakage

---

## Performance Considerations

### Database Optimization

**Isar Indexes**:
- `serverId` - Unique index for fast lookups
- `createdAt`, `updatedAt` - Indexed for sorting
- Composite indexes could be added for complex queries

**Query Optimization**:
```dart
// Good: Indexed query
await isar.notes.filter().serverIdEqualTo(serverId).findFirst();

// Good: Sorted by indexed field
await isar.notes.where().sortByUpdatedAtDesc().findAll();

// Avoid: Full table scan
await isar.notes.filter().titleContains(query).findAll();
```

### Network Optimization

**Firestore Queries**:
- Single query gets all user's notes: `where('permissions.userId', !=, null)`
- Real-time listener only for notes user has access to
- Batch operations for multiple updates

**Caching**:
- Firestore has built-in offline persistence
- Isar provides instant local access
- No additional caching layer needed

### UI Performance

**Optimizations**:
- `const` constructors where possible
- `ListView.builder` for large lists
- Hero animations for smooth transitions
- Debounced search input
- Lazy loading (could be added for 1000+ notes)

**Avoid**:
- Rebuilding entire widget tree
- Synchronous operations on main thread
- Large images without caching
- Complex computations in build methods

---

## Future Enhancements

### Potential Improvements

1. **Rich Text Editor** - Markdown or WYSIWYG
2. **File Attachments** - Images, PDFs
3. **Tags & Categories** - Better organization
4. **Version History** - Track changes over time
5. **Conflict Resolution UI** - Let user choose between versions
6. **Presence Indicators** - See who's viewing/editing
7. **Real-Time Cursors** - Collaborative editing like Google Docs
8. **Export** - PDF, Markdown, HTML
9. **Encryption** - End-to-end encryption for sensitive notes
10. **Web & Desktop** - Flutter supports all platforms

### Scalability Considerations

**Current Limits**:
- Firestore: 1MB per document (supports ~10,000 collaborators)
- Isar: No practical limit on local storage
- Real-time listeners: 100 concurrent per client

**Scaling Strategy**:
- Pagination for 1000+ notes
- Lazy loading of note content
- Separate collection for large attachments
- CDN for media files

---

## Conclusion

AnchorNotes demonstrates a production-ready architecture for offline-first, collaborative applications. The single source of truth pattern eliminates sync conflicts, while the service-oriented design keeps code maintainable and testable.

**Key Takeaways**:
- Offline-first is achievable with proper architecture
- Single source of truth eliminates complexity
- Service layer separates concerns effectively
- Real-time collaboration is simpler than it seems
- Security rules are critical for multi-user apps

---

**Last Updated**: October 16, 2025
