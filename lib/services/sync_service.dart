import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../models/folder.dart';
import 'auth_service.dart';
import 'isar_service.dart';
import 'folder_service.dart';

/// SyncService
/// Manages bidirectional sync between local Isar database and Cloud Firestore
/// Implements "Last Write Wins" conflict resolution strategy
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final IsarService _isarService = IsarService();
  final FolderService _folderService = FolderService();

  StreamSubscription? _firestoreSubscription;
  StreamSubscription? _folderSubscription;
  bool _isSyncing = false;
  String _syncStatus = 'idle'; // 'idle', 'syncing', 'synced', 'error'

  /// Get current sync status
  String get syncStatus => _syncStatus;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  // ==================== Initialization ====================

  /// Initialize sync service and start real-time listener
  Future<void> initialize() async {
    if (_authService.userId == null) {
      debugPrint('SyncService: No user logged in, skipping initialization');
      return;
    }

    debugPrint('SyncService: Initializing for user ${_authService.userId}');
    
    // Start listening to Firestore changes
    _startFirestoreListener();
    _startFolderListener();
    
    // Wait a bit for initial Firestore data to sync
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check if user has any notes
    final localNotes = await _isarService.getAllNotes();
    final firestoreNotes = await _firestore
        .collection('notes')
        .where('permissions.${_authService.userId}', isNotEqualTo: null)
        .get();
    
    // Only create welcome note if user has no notes anywhere
    if (localNotes.isEmpty && firestoreNotes.docs.isEmpty) {
      debugPrint('SyncService: Creating welcome note for new user');
      await _createWelcomeNote();
    } else {
      debugPrint('SyncService: User has ${localNotes.length} local notes and ${firestoreNotes.docs.length} Firestore notes');
    }
    
    // Push any pending local changes
    await _pushPendingChanges();
  }

  /// Create welcome note for new users
  Future<void> _createWelcomeNote() async {
    final welcomeNote = Note()
      ..title = 'Welcome to SyncPad'
      ..content = 'Start writing your thoughts here...\n\nThis is your offline-first note-taking app.'
      ..ownerId = _authService.userId!
      ..permission = 'owner'
      ..syncStatus = 'pending';
    
    await _isarService.createNote(welcomeNote);
    await pushNote(welcomeNote);
  }

  /// Stop sync service and cleanup
  Future<void> dispose() async {
    debugPrint('SyncService: Disposing');
    await _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }

  // ==================== Push: Local → Firestore ====================

  /// Push a single note to Firestore (Single source of truth)
  Future<void> pushNote(Note note) async {
    if (_authService.userId == null) {
      debugPrint('SyncService: Cannot push note, user not logged in');
      return;
    }

    // Don't push notes that user doesn't own or have edit permission for
    if (!note.canEdit) {
      debugPrint('SyncService: Skipping push for note ${note.id} - user cannot edit (permission: ${note.permission})');
      return;
    }

    try {
      _setSyncStatus('syncing');

      // If note doesn't have a serverId yet, create new document
      if (note.serverId == null) {
        // Prepare note data with initial permissions
        final noteData = {
          'title': note.title,
          'content': note.content,
          'createdAt': note.createdAt.toIso8601String(),
          'updatedAt': note.updatedAt.toIso8601String(),
          'ownerId': note.ownerId.isNotEmpty ? note.ownerId : _authService.userId!,
          'permissions': {
            _authService.userId!: 'owner',
          },
        };
        
        // Create new note in Firestore
        final docRef = await _firestore.collection('notes').add(noteData);
        
        // Update local note with serverId
        final updatedNote = note.copyWith(
          serverId: docRef.id,
          ownerId: _authService.userId!,
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        );
        await _isarService.updateNote(updatedNote);
        
        debugPrint('SyncService: Created new note with serverId: ${docRef.id}');
      } else {
        // Update existing note in Firestore (only content, not permissions)
        // Use set with merge to avoid permission errors if document doesn't exist
        await _firestore
            .collection('notes')
            .doc(note.serverId)
            .set({
          'title': note.title,
          'content': note.content,
          'updatedAt': note.updatedAt.toIso8601String(),
        }, SetOptions(merge: true));

        
        // Update local sync status
        final updatedNote = note.copyWith(
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        );
        await _isarService.updateNote(updatedNote);
        
        debugPrint('SyncService: Updated note ${note.serverId}');
      }

      _setSyncStatus('synced');
      debugPrint('SyncService: Pushed note ${note.id} to Firestore');
    } catch (e) {
      _setSyncStatus('error');
      debugPrint('SyncService: Error pushing note: $e');
      
      // Mark note as having sync error
      final errorNote = note.copyWith(syncStatus: 'error');
      await _isarService.updateNote(errorNote);
      
      rethrow;
    }
  }

  /// Push all pending local changes to Firestore
  Future<void> _pushPendingChanges() async {
    if (_authService.userId == null) return;

    try {
      final allNotes = await _isarService.getAllNotes();
      final pendingNotes = allNotes.where((note) => 
        note.syncStatus == 'pending' || note.syncStatus == 'error'
      ).toList();

      debugPrint('SyncService: Pushing ${pendingNotes.length} pending notes');

      for (final note in pendingNotes) {
        await pushNote(note);
      }
    } catch (e) {
      debugPrint('SyncService: Error pushing pending changes: $e');
    }
  }

  /// Force sync all notes (manual sync)
  Future<void> syncAll() async {
    if (_authService.userId == null) {
      throw 'User not logged in';
    }

    _setSyncStatus('syncing');

    try {
      // Push all local notes
      final allNotes = await _isarService.getAllNotes();
      for (final note in allNotes) {
        await pushNote(note);
      }

      _setSyncStatus('synced');
      debugPrint('SyncService: Synced all notes');
    } catch (e) {
      _setSyncStatus('error');
      debugPrint('SyncService: Error syncing all notes: $e');
      rethrow;
    }
  }

  // ==================== Pull: Firestore → Local ====================

  /// Start real-time listener for Firestore changes
  /// Listens to all notes where user has permission
  void _startFirestoreListener() {
    if (_authService.userId == null) return;

    // Cancel existing subscription
    _firestoreSubscription?.cancel();

    debugPrint('SyncService: Starting Firestore listener for user ${_authService.userId}');

    // Query for all notes where current user has permission
    _firestoreSubscription = _firestore
        .collection('notes')
        .where('permissions.${_authService.userId}', isNotEqualTo: null)
        .snapshots()
        .listen(
          _handleFirestoreSnapshot,
          onError: (error) {
            debugPrint('SyncService: Firestore listener error: $error');
            _setSyncStatus('error');
          },
        );
  }

  /// Handle Firestore snapshot changes
  Future<void> _handleFirestoreSnapshot(QuerySnapshot snapshot) async {
    debugPrint('SyncService: Received ${snapshot.docs.length} notes from Firestore');
    debugPrint('SyncService: Document changes: ${snapshot.docChanges.length}');

    // Process document changes
    for (final change in snapshot.docChanges) {
      try {
        final data = change.doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        // Safety check: Verify user has permission for this note
        final permissions = Map<String, dynamic>.from(data['permissions'] ?? {});
        if (!permissions.containsKey(_authService.userId)) {
          debugPrint('SyncService: Skipping note ${change.doc.id} - user has no permission');
          continue;
        }

        final remoteNote = Note.fromFirestore(
          change.doc.id,
          data,
          _authService.userId!,
        );
        
        debugPrint('SyncService: Change type: ${change.type}, ServerId: ${remoteNote.serverId}, Title: ${remoteNote.title}');

        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            await _handleRemoteNoteUpdate(remoteNote);
            break;
          case DocumentChangeType.removed:
            // The note was removed from our query result set. This means our
            // permission was revoked or the note was deleted by the owner.
            debugPrint('SyncService: Permission revoked or note deleted: ${remoteNote.serverId}');
            await _handleRemoteNoteDelete(remoteNote.serverId!);
            break;
        }
      } catch (e) {
        debugPrint('SyncService: Error handling Firestore change: $e');
      }
    }

    // Clean up local notes that are no longer in Firestore
    await _cleanupOrphanedNotes(snapshot);

    _setSyncStatus('synced');
  }

  /// Remove local notes that no longer exist in Firestore or user lost access to
  Future<void> _cleanupOrphanedNotes(QuerySnapshot snapshot) async {
    try {
      // Get all local notes with serverIds
      final localNotes = await _isarService.getAllNotes();
      final localNotesWithServerId = localNotes.where((n) => n.serverId != null).toList();
      
      // Get serverIds from Firestore snapshot
      final firestoreServerIds = snapshot.docs.map((doc) => doc.id).toSet();
      
      debugPrint('SyncService: Cleanup check - Local: ${localNotesWithServerId.length} notes, Firestore: ${firestoreServerIds.length} notes');
      
      // Find notes that exist locally but not in Firestore
      for (final localNote in localNotesWithServerId) {
        if (!firestoreServerIds.contains(localNote.serverId)) {
          debugPrint('SyncService: Removing orphaned note ${localNote.serverId} (${localNote.title}) - no longer accessible');
          await _isarService.deleteNote(localNote.id);
        }
      }
    } catch (e) {
      debugPrint('SyncService: Error cleaning up orphaned notes: $e');
    }
  }

  /// Handle remote note update (Last Write Wins)
  Future<void> _handleRemoteNoteUpdate(Note remoteNote) async {
    final localNote = await _isarService.getNoteByServerId(remoteNote.serverId!);

    if (localNote == null) {
      // New note from remote, add to local
      debugPrint('SyncService: Adding new note ${remoteNote.serverId} from remote');
      await _isarService.createNote(remoteNote);
    } else {
      // Last Write Wins: Compare timestamps
      if (remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
        // Remote is newer, update local
        debugPrint('SyncService: Remote note ${remoteNote.serverId} is newer. Updating local.');
        debugPrint('SyncService: Remote: ${remoteNote.updatedAt}, Local: ${localNote.updatedAt}');
        
        // Preserve local ID when updating
        final updatedNote = remoteNote.copyWith(id: localNote.id);
        await _isarService.updateNote(updatedNote);
      } else if (remoteNote.updatedAt.isBefore(localNote.updatedAt)) {
        // Local is newer, push to remote
        debugPrint('SyncService: Local note ${remoteNote.serverId} is newer. Pushing to remote.');
        await pushNote(localNote);
      } else {
        // Timestamps match, but still update permission in case it changed
        if (remoteNote.permission != localNote.permission) {
          debugPrint('SyncService: Updating permission for note ${remoteNote.serverId}');
          final updatedNote = localNote.copyWith(permission: remoteNote.permission);
          await _isarService.updateNote(updatedNote);
        } else {
          debugPrint('SyncService: Note ${remoteNote.serverId} is identical, skipping');
        }
      }
    }
  }

  /// Handle remote note deletion or permission revocation
  /// This is called when a DocumentChangeType.removed event is received
  Future<void> _handleRemoteNoteDelete(String serverId) async {
    debugPrint('SyncService: Attempting to delete note $serverId from local database');
    final deleted = await _isarService.deleteNoteByServerId(serverId);
    if (deleted) {
      debugPrint('SyncService: ✅ Successfully deleted note $serverId from local');
    } else {
      debugPrint('SyncService: ⚠️ Note $serverId not found in local database (may already be deleted)');
    }
  }

  // ==================== Delete with Sync ====================

  /// Delete note from both local and Firestore
  Future<void> deleteNote(int noteId) async {
    if (_authService.userId == null) {
      throw 'User not logged in';
    }

    try {
      // Get the note to find its serverId
      final note = await _isarService.getNote(noteId);
      if (note == null) {
        debugPrint('SyncService: Note $noteId not found locally');
        return;
      }

      // Delete from Firestore if it has a serverId
      if (note.serverId != null) {
        await _firestore
            .collection('notes')
            .doc(note.serverId)
            .delete();
      }

      // Delete from local
      await _isarService.deleteNote(noteId);

      debugPrint('SyncService: Deleted note $noteId (serverId: ${note.serverId})');
    } catch (e) {
      debugPrint('SyncService: Error deleting note: $e');
      rethrow;
    }
  }
  // ==================== Utility Methods ====================

  /// Set sync status and notify listeners
  void _setSyncStatus(String status) {
    _syncStatus = status;
    _isSyncing = status == 'syncing';
    debugPrint('SyncService: Status changed to $status');
  }

  /// Get user-friendly error message from exception
  String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'No internet connection. Changes will sync when online.';
    } else if (errorString.contains('permission')) {
      return 'Permission denied. You may not have access to this note.';
    } else if (errorString.contains('not found')) {
      return 'Note not found. It may have been deleted.';
    } else if (errorString.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else {
      return 'Sync failed. Your changes are saved locally.';
    }
  }

  /// Retry failed sync operations
  Future<void> retryFailedSyncs() async {
    if (_authService.userId == null) return;
    
    try {
      _setSyncStatus('syncing');
      
      // Get all notes with error status
      final allNotes = await _isarService.getAllNotes();
      final failedNotes = allNotes.where((note) => note.syncStatus == 'error').toList();
      
      debugPrint('SyncService: Retrying ${failedNotes.length} failed syncs');
      
      for (final note in failedNotes) {
        try {
          await pushNote(note);
        } catch (e) {
          debugPrint('SyncService: Retry failed for note ${note.id}: $e');
          // Continue with other notes
        }
      }
      
      _setSyncStatus('synced');
    } catch (e) {
      _setSyncStatus('error');
      debugPrint('SyncService: Error retrying syncs: $e');
    }
  }

  /// Check if device is online (simplified)
  Future<bool> isOnline() async {
    try {
      // Try to access Firestore
      await _firestore
          .collection('_health_check')
          .doc('test')
          .get()
          .timeout(const Duration(seconds: 3));
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== Folder Sync ====================

  /// Start listening to folder changes from Firestore
  void _startFolderListener() {
    final userId = _authService.userId;
    if (userId == null) return;

    debugPrint('SyncService: Starting folder listener for user $userId');

    _folderSubscription = _firestore
        .collection('folders')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) async {
        debugPrint('SyncService: Received ${snapshot.docs.length} folders from Firestore');

        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            final folder = Folder.fromFirestore(doc.id, data, userId);

            // Check if folder exists locally
            final existingFolder = await _folderService.getFolderByServerId(doc.id);

            if (existingFolder == null) {
              // New folder from Firestore
              debugPrint('SyncService: Creating new folder from Firestore: ${folder.name}');
              await _folderService.createFolder(folder);
            } else {
              // Update existing folder (Last Write Wins)
              if (folder.updatedAt.isAfter(existingFolder.updatedAt)) {
                debugPrint('SyncService: Updating folder from Firestore: ${folder.name}');
                final updatedFolder = existingFolder.copyWith(
                  name: folder.name,
                  color: folder.color,
                  icon: folder.icon,
                  updatedAt: folder.updatedAt,
                  syncStatus: 'synced',
                  lastSyncedAt: DateTime.now(),
                );
                await _folderService.updateFolder(updatedFolder);
              }
            }
          } catch (e) {
            debugPrint('SyncService: Error processing folder ${doc.id}: $e');
          }
        }
      },
      onError: (error) {
        debugPrint('SyncService: Folder listener error: $error');
      },
    );
  }

  /// Push a folder to Firestore
  Future<void> pushFolder(Folder folder) async {
    final userId = _authService.userId;
    if (userId == null) {
      debugPrint('SyncService: Cannot push folder - no user logged in');
      return;
    }

    try {
      // Set owner ID
      folder.ownerId = userId;

      if (folder.serverId == null) {
        // Create new folder in Firestore
        final docRef = await _firestore.collection('folders').add(folder.toFirestore());
        
        // Update local folder with serverId
        final updatedFolder = folder.copyWith(
          serverId: docRef.id,
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        );
        await _folderService.updateFolder(updatedFolder);
        
        debugPrint('SyncService: Created folder in Firestore: ${docRef.id}');
      } else {
        // Update existing folder in Firestore
        await _firestore
            .collection('folders')
            .doc(folder.serverId)
            .set(folder.toFirestore(), SetOptions(merge: true));
        
        // Update sync status
        final updatedFolder = folder.copyWith(
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        );
        await _folderService.updateFolder(updatedFolder);
        
        debugPrint('SyncService: Updated folder in Firestore: ${folder.serverId}');
      }
    } catch (e) {
      debugPrint('SyncService: Error pushing folder: $e');
      
      // Mark as error
      final errorFolder = folder.copyWith(syncStatus: 'error');
      await _folderService.updateFolder(errorFolder);
      
      rethrow;
    }
  }

  /// Delete a folder from Firestore
  Future<void> deleteFolder(String serverId) async {
    try {
      await _firestore.collection('folders').doc(serverId).delete();
      debugPrint('SyncService: Deleted folder from Firestore: $serverId');
    } catch (e) {
      debugPrint('SyncService: Error deleting folder: $e');
      rethrow;
    }
  }

  /// Sync all local folders to Firestore
  Future<void> syncAllFolders() async {
    final userId = _authService.userId;
    if (userId == null) return;

    try {
      final folders = await _folderService.getAllFolders();
      debugPrint('SyncService: Syncing ${folders.length} folders to Firestore');

      for (final folder in folders) {
        if (folder.syncStatus != 'synced') {
          await pushFolder(folder);
        }
      }
    } catch (e) {
      debugPrint('SyncService: Error syncing folders: $e');
    }
  }
}
