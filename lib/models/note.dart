import 'package:isar/isar.dart';

part 'note.g.dart';

/// Note Model
/// Represents a single note in the SyncPad application
/// Uses Isar for offline-first local storage
@collection
class Note {
  /// Unique identifier for the note
  /// Auto-incremented by Isar
  Id id = Isar.autoIncrement;

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
  /// Used for sorting and displaying "last edited" info
  @Index()
  late DateTime updatedAt;

  /// User ID who owns this note (for multi-user support)
  String userId = '';

  /// Sync status: 'synced', 'pending', 'error'
  String syncStatus = 'pending';

  /// Last sync timestamp (null if never synced)
  DateTime? lastSyncedAt;

  /// Shared with users (list of user IDs with access)
  List<String> sharedWith = [];

  /// Sharing permissions: 'owner', 'editor', 'viewer'
  String permission = 'owner';

  /// Default constructor for Isar
  Note() {
    final now = DateTime.now();
    createdAt = now;
    updatedAt = now;
  }

  /// Create a copy of the note with updated fields
  Note copyWith({
    Id? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? syncStatus,
    DateTime? lastSyncedAt,
    List<String>? sharedWith,
    String? permission,
  }) {
    final note = Note();
    note.id = id ?? this.id;
    note.title = title ?? this.title;
    note.content = content ?? this.content;
    note.createdAt = createdAt ?? this.createdAt;
    note.updatedAt = updatedAt ?? this.updatedAt;
    note.userId = userId ?? this.userId;
    note.syncStatus = syncStatus ?? this.syncStatus;
    note.lastSyncedAt = lastSyncedAt ?? this.lastSyncedAt;
    note.sharedWith = sharedWith ?? List.from(this.sharedWith);
    note.permission = permission ?? this.permission;
    return note;
  }

  /// Check if the note is empty (no title and no content)
  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;

  /// Get a preview of the content (first line, max 100 characters)
  String get preview {
    if (content.trim().isEmpty) return 'No content';
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
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'sharedWith': sharedWith,
      'permission': permission,
    };
  }

  /// Create Note from Firestore document
  static Note fromFirestore(Map<String, dynamic> data) {
    final note = Note();
    note.id = data['id'] ?? Isar.autoIncrement;
    note.title = data['title'] ?? '';
    note.content = data['content'] ?? '';
    note.createdAt = DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String());
    note.updatedAt = DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String());
    note.userId = data['userId'] ?? '';
    note.sharedWith = List<String>.from(data['sharedWith'] ?? []);
    note.permission = data['permission'] ?? 'owner';
    note.syncStatus = 'synced';
    note.lastSyncedAt = DateTime.now();
    return note;
  }
  
  /// Check if note is shared
  bool get isShared => sharedWith.isNotEmpty;
  
  /// Check if user can edit (owner or editor)
  bool get canEdit => permission == 'owner' || permission == 'editor';
  
  /// Check if user is owner
  bool get isOwner => permission == 'owner';

  @override
  String toString() {
    return 'Note(id: $id, title: "$title", content: "${content.substring(0, content.length > 50 ? 50 : content.length)}...", createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }
}
