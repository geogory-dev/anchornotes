import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import 'auth_service.dart';
import 'isar_service.dart';

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

  StreamSubscription? _firestoreSubscription;
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
    
    // Push any pending local changes
    await _pushPendingChanges();
  }

  /// Stop sync service and cleanup
  Future<void> dispose() async {
    debugPrint('SyncService: Disposing');
    await _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }

  // ==================== Push: Local → Firestore ====================

  /// Push a single note to Firestore
  Future<void> pushNote(Note note) async {
    if (_authService.userId == null) {
      debugPrint('SyncService: Cannot push note, user not logged in');
      return;
    }

    try {
      _setSyncStatus('syncing');

      // Set user ID if not already set
      if (note.userId.isEmpty) {
        note.userId = _authService.userId!;
      }

      // Push to Firestore
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('notes')
          .doc(note.id.toString())
          .set(note.toFirestore(), SetOptions(merge: true));

      // Update local sync status
      final updatedNote = note.copyWith(
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now(),
      );
      await _isarService.updateNote(updatedNote);

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
  void _startFirestoreListener() {
    if (_authService.userId == null) return;

    // Cancel existing subscription
    _firestoreSubscription?.cancel();

    debugPrint('SyncService: Starting Firestore listener');

    _firestoreSubscription = _firestore
        .collection('users')
        .doc(_authService.userId)
        .collection('notes')
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

    for (final change in snapshot.docChanges) {
      try {
        final data = change.doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final remoteNote = Note.fromFirestore(data);

        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            await _handleRemoteNoteUpdate(remoteNote);
            break;
          case DocumentChangeType.removed:
            await _handleRemoteNoteDelete(remoteNote);
            break;
        }
      } catch (e) {
        debugPrint('SyncService: Error handling Firestore change: $e');
      }
    }

    _setSyncStatus('synced');
  }

  /// Handle remote note update (Last Write Wins)
  Future<void> _handleRemoteNoteUpdate(Note remoteNote) async {
    final localNote = await _isarService.getNote(remoteNote.id);

    if (localNote == null) {
      // New note from remote, add to local
      debugPrint('SyncService: Adding new note ${remoteNote.id} from remote');
      await _isarService.createNote(remoteNote);
    } else {
      // Check if content is different
      final isDifferent = remoteNote.title != localNote.title || 
                         remoteNote.content != localNote.content;
      
      if (!isDifferent) {
        debugPrint('SyncService: Note ${remoteNote.id} content is same, skipping');
        return;
      }
      
      debugPrint('SyncService: Content changed - Remote: "${remoteNote.content.substring(0, 30)}..." vs Local: "${localNote.content.substring(0, 30)}..."');
      debugPrint('SyncService: Remote updatedAt: ${remoteNote.updatedAt}, Local updatedAt: ${localNote.updatedAt}');
      
      // If content is different, always update from remote
      // This allows manual edits from Firebase Console to work
      debugPrint('SyncService: Content is different, updating from remote');
      await _isarService.updateNote(remoteNote);
    }
  }

  /// Handle remote note deletion
  Future<void> _handleRemoteNoteDelete(Note remoteNote) async {
    debugPrint('SyncService: Deleting note ${remoteNote.id} from local');
    await _isarService.deleteNote(remoteNote.id);
  }

  // ==================== Delete with Sync ====================

  /// Delete note from both local and Firestore
  Future<void> deleteNote(int noteId) async {
    if (_authService.userId == null) {
      throw 'User not logged in';
    }

    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('notes')
          .doc(noteId.toString())
          .delete();

      // Delete from local
      await _isarService.deleteNote(noteId);

      debugPrint('SyncService: Deleted note $noteId');
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

  /// Get sync status icon based on current state
  String getSyncStatusIcon() {
    switch (_syncStatus) {
      case 'syncing':
        return 'sync';
      case 'synced':
        return 'cloud_done';
      case 'error':
        return 'cloud_off';
      default:
        return 'cloud_queue';
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
}
