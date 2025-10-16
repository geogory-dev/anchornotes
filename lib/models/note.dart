import 'dart:convert';
import 'package:isar/isar.dart';

part 'note.g.dart';

/// Note Model
/// Represents a single note in the SyncPad application
/// Uses Isar for offline-first local storage
@collection
class Note {
  /// Local unique identifier for the note
  /// Auto-incremented by Isar
  Id id = Isar.autoIncrement;

  /// Firestore document ID (server-side ID)
  /// Unique across all users, used as single source of truth
  @Index(unique: true, replace: true)
  String? serverId;

  /// Title of the note
  /// Can be empty for untitled notes
  @Index()
  String title = '';

  /// Content/body of the note
  /// Main text area for writing
  String content = '';

  /// Timestamp when the note was created
  @Index()
  late DateTime createdAt;

  /// Timestamp when the note was last updated
  /// Used for sorting and "last write wins" conflict resolution
  @Index()
  late DateTime updatedAt;

  /// User ID who owns this note
  String ownerId = '';

  /// Current user's permission level for this note
  /// 'owner', 'editor', or 'viewer'
  String permission = 'owner';

  /// Sync status: 'synced', 'pending', 'error'
  String syncStatus = 'pending';

  /// Last sync timestamp (null if never synced)
  DateTime? lastSyncedAt;

  /// Folder ID (optional - notes can be in a folder)
  String? folderId;

  /// Folder name (for display, synced from folder)
  String folderName = '';

  /// Is this note favorited/pinned?
  bool isFavorite = false;

  /// Default constructor for Isar
  Note() {
    final now = DateTime.now();
    createdAt = now;
    updatedAt = now;
  }

  /// Create a copy of the note with updated fields
  Note copyWith({
    Id? id,
    String? serverId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
    String? permission,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? folderId,
    String? folderName,
    bool? isFavorite,
  }) {
    final note = Note();
    note.id = id ?? this.id;
    note.serverId = serverId ?? this.serverId;
    note.title = title ?? this.title;
    note.content = content ?? this.content;
    note.createdAt = createdAt ?? this.createdAt;
    note.updatedAt = updatedAt ?? this.updatedAt;
    note.ownerId = ownerId ?? this.ownerId;
    note.permission = permission ?? this.permission;
    note.syncStatus = syncStatus ?? this.syncStatus;
    note.lastSyncedAt = lastSyncedAt ?? this.lastSyncedAt;
    note.folderId = folderId ?? this.folderId;
    note.folderName = folderName ?? this.folderName;
    note.isFavorite = isFavorite ?? this.isFavorite;
    return note;
  }

  /// Check if the note is empty (no title and no content)
  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;

  /// Get a preview of the content (first line, max 100 characters)
  String get preview {
    if (content.trim().isEmpty) return 'No content';
    
    // Check if content is JSON (rich text format)
    if (content.startsWith('[') && content.contains('"insert"')) {
      try {
        // Parse Quill Delta JSON and extract plain text
        final dynamic decoded = jsonDecode(content);
        if (decoded is List) {
          final buffer = StringBuffer();
          for (final op in decoded) {
            if (op is Map && op.containsKey('insert')) {
              buffer.write(op['insert'].toString());
            }
          }
          final plainText = buffer.toString().trim();
          if (plainText.isEmpty) return 'No content';
          final firstLine = plainText.split('\n').first.trim();
          if (firstLine.length <= 100) return firstLine;
          return '${firstLine.substring(0, 100)}...';
        }
      } catch (e) {
        // If JSON parsing fails, fall back to plain text
      }
    }
    
    // Plain text content
    final firstLine = content.split('\n').first.trim();
    if (firstLine.length <= 100) return firstLine;
    return '${firstLine.substring(0, 100)}...';
  }

  /// Get a display title (use "Untitled" if title is empty)
  String get displayTitle {
    if (title.trim().isEmpty) return 'Untitled';
    return title;
  }

  /// Convert Note to Firestore document (Map)
  Map<String, dynamic> toFirestore(String currentUserId) {
    // Get current permissions map from Firestore or create new one
    final permissions = <String, String>{};
    permissions[ownerId.isNotEmpty ? ownerId : currentUserId] = permission;
    
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'ownerId': ownerId.isNotEmpty ? ownerId : currentUserId,
      'permissions': permissions,
    };
  }

  /// Create Note from Firestore document
  static Note fromFirestore(String docId, Map<String, dynamic> data, String currentUserId) {
    final note = Note();
    note.serverId = docId;
    note.title = data['title'] ?? '';
    note.content = data['content'] ?? '';
    note.createdAt = DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String());
    note.updatedAt = DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String());
    note.ownerId = data['ownerId'] ?? '';
    
    // Get current user's permission from permissions map
    final permissions = Map<String, dynamic>.from(data['permissions'] ?? {});
    note.permission = permissions[currentUserId] ?? 'viewer';
    
    note.syncStatus = 'synced';
    note.lastSyncedAt = DateTime.now();
    return note;
  }
  
  /// Check if note is shared (has more than one person in permissions)
  bool get isShared => false; // Will be determined by permissions map in Firestore
  
  /// Check if user can edit (owner or editor)
  bool get canEdit => permission == 'owner' || permission == 'editor';
  
  /// Check if user is owner
  bool get isOwner => permission == 'owner';

  @override
  String toString() {
    return 'Note(id: $id, serverId: $serverId, title: "$title", permission: $permission, syncStatus: $syncStatus)';
  }
}
