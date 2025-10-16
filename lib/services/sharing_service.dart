import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import 'auth_service.dart';
import 'isar_service.dart';
import 'sync_service.dart';

/// SharingService
/// Handles note sharing and collaboration features
class SharingService {
  static final SharingService _instance = SharingService._internal();
  factory SharingService() => _instance;
  SharingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  // ==================== Share Note ====================

  /// Share a note with another user by email
  /// Updates the permissions map in the single source of truth
  Future<void> shareNoteWithEmail({
    required Note note,
    required String email,
    required String permission, // 'editor' or 'viewer'
  }) async {
    if (_authService.userId == null) {
      throw 'User not logged in';
    }

    if (!note.isOwner) {
      throw 'Only the owner can share this note';
    }

    if (note.serverId == null) {
      throw 'Cannot share an unsynced note';
    }

    try {
      // Find user by email
      debugPrint('SharingService: Looking for email: ${email.trim().toLowerCase()}');
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw 'User with email $email not found';
      }

      final targetUserId = userQuery.docs.first.id;

      // Don't share with yourself
      if (targetUserId == _authService.userId) {
        throw 'Cannot share note with yourself';
      }

      // Update permissions map in Firestore (single source of truth)
      // Use dot notation to add/update a specific key in the permissions map
      debugPrint('SharingService: Adding $targetUserId to permissions with $permission');
      await _firestore
          .collection('notes')
          .doc(note.serverId)
          .update({
        'permissions.$targetUserId': permission,
      });

      debugPrint('SharingService: Successfully shared note ${note.serverId} with $email as $permission');
    } catch (e) {
      debugPrint('SharingService: Error sharing note: $e');
      rethrow;
    }
  }

  /// Remove a user from shared note
  /// Removes user from permissions map
  Future<void> unshareNote({
    required Note note,
    required String userId,
  }) async {
    if (_authService.userId == null) {
      throw 'User not logged in';
    }

    if (!note.isOwner) {
      throw 'Only the owner can unshare this note';
    }

    if (note.serverId == null) {
      throw 'Cannot unshare an unsynced note';
    }

    try {
      // Remove user from permissions map using FieldValue.delete()
      debugPrint('SharingService: Removing $userId from permissions');
      await _firestore
          .collection('notes')
          .doc(note.serverId)
          .update({
        'permissions.$userId': FieldValue.delete(),
      });

      debugPrint('SharingService: Unshared note ${note.serverId} from user $userId');
    } catch (e) {
      debugPrint('SharingService: Error unsharing note: $e');
      rethrow;
    }
  }

  /// Update permission for a shared user
  /// Updates the permission in the permissions map
  Future<void> updatePermission({
    required Note note,
    required String userId,
    required String newPermission,
  }) async {
    if (_authService.userId == null) {
      throw 'User not logged in';
    }

    if (!note.isOwner) {
      throw 'Only the owner can change permissions';
    }

    if (note.serverId == null) {
      throw 'Cannot update permission for an unsynced note';
    }

    try {
      // Update permission in permissions map
      debugPrint('SharingService: Updating permission for $userId to $newPermission');
      await _firestore
          .collection('notes')
          .doc(note.serverId)
          .update({
        'permissions.$userId': newPermission,
      });

      debugPrint('SharingService: Updated permission for user $userId to $newPermission');
    } catch (e) {
      debugPrint('SharingService: Error updating permission: $e');
      rethrow;
    }
  }

  // ==================== Get Collaborators ====================

  /// Get list of collaborators for a note
  /// Reads from the permissions map in Firestore
  Future<List<Map<String, dynamic>>> getCollaborators(Note note) async {
    if (_authService.userId == null) {
      throw 'User not logged in';
    }

    if (note.serverId == null) {
      return [];
    }

    try {
      final collaborators = <Map<String, dynamic>>[];

      // Get the note document to access permissions map
      final noteDoc = await _firestore
          .collection('notes')
          .doc(note.serverId)
          .get();

      if (!noteDoc.exists) {
        return [];
      }

      final noteData = noteDoc.data();
      final permissions = Map<String, dynamic>.from(noteData?['permissions'] ?? {});

      // Iterate through permissions map
      for (final entry in permissions.entries) {
        final userId = entry.key;
        final permission = entry.value as String;

        // Skip the owner (current user)
        if (userId == _authService.userId) continue;

        // Get user info
        final userDoc = await _firestore.collection('users').doc(userId).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data();
          collaborators.add({
            'userId': userId,
            'email': userData?['email'] ?? 'Unknown',
            'permission': permission,
          });
        }
      }

      return collaborators;
    } catch (e) {
      debugPrint('SharingService: Error getting collaborators: $e');
      return [];
    }
  }

  // ==================== User Email Lookup ====================

  /// Store user email in Firestore (call on login/signup)
  Future<void> storeUserEmail(String userId, String email) async {
    try {
      debugPrint('SharingService: Attempting to store email $email for user $userId');
      
      await _firestore.collection('users').doc(userId).set({
        'email': email.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('SharingService: Successfully stored email for user $userId');
      
      // Verify it was stored
      final doc = await _firestore.collection('users').doc(userId).get();
      debugPrint('SharingService: Verification - User doc data: ${doc.data()}');
    } catch (e) {
      debugPrint('SharingService: Error storing user email: $e');
      rethrow; // Re-throw so we know it failed
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('SharingService: Error checking email: $e');
      return false;
    }
  }
}
