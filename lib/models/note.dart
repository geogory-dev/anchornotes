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
  }) {
    final note = Note();
    note.id = id ?? this.id;
    note.title = title ?? this.title;
    note.content = content ?? this.content;
    note.createdAt = createdAt ?? this.createdAt;
    note.updatedAt = updatedAt ?? this.updatedAt;
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

  @override
  String toString() {
    return 'Note(id: $id, title: "$title", content: "${content.substring(0, content.length > 50 ? 50 : content.length)}...", createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
