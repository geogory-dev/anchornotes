import 'package:isar/isar.dart';

part 'folder.g.dart';

/// Folder Model
/// Represents a folder/category for organizing notes
@collection
class Folder {
  /// Local Isar ID (auto-increment)
  Id id = Isar.autoIncrement;

  /// Firestore document ID (unique across users)
  @Index(unique: true, replace: true)
  String? serverId;

  /// Unique folder identifier (used for note references)
  /// Generated locally, synced to Firestore
  @Index(unique: true)
  late String folderId;

  /// Folder name
  late String name;

  /// Folder color (hex string)
  String color = '#2196F3'; // Default blue

  /// Folder icon (emoji or icon name)
  String icon = '📁';

  /// Owner's user ID
  String ownerId = '';

  /// Creation timestamp
  @Index()
  late DateTime createdAt;

  /// Last update timestamp
  @Index()
  late DateTime updatedAt;

  /// Sync status: 'pending', 'synced', 'error'
  String syncStatus = 'pending';

  /// Last sync timestamp
  DateTime? lastSyncedAt;

  /// Number of notes in this folder (computed)
  @ignore
  int noteCount = 0;

  /// Constructor
  Folder() {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    // Generate unique folder ID
    folderId = 'folder_${DateTime.now().millisecondsSinceEpoch}_${createdAt.microsecond}';
  }

  /// Create Folder from Firestore document
  static Folder fromFirestore(String docId, Map<String, dynamic> data, String currentUserId) {
    final folder = Folder();
    folder.serverId = docId;
    folder.folderId = data['folderId'] ?? folder.folderId; // Use synced folderId or keep generated one
    folder.name = data['name'] ?? '';
    folder.color = data['color'] ?? '#2196F3';
    folder.icon = data['icon'] ?? '📁';
    folder.ownerId = data['ownerId'] ?? '';
    folder.createdAt = DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String());
    folder.updatedAt = DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String());
    folder.syncStatus = 'synced';
    folder.lastSyncedAt = DateTime.now();
    return folder;
  }

  /// Convert Folder to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'folderId': folderId,
      'name': name,
      'color': color,
      'icon': icon,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Folder copyWith({
    int? id,
    String? serverId,
    String? folderId,
    String? name,
    String? color,
    String? icon,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    final folder = Folder();
    folder.id = id ?? this.id;
    folder.serverId = serverId ?? this.serverId;
    folder.folderId = folderId ?? this.folderId;
    folder.name = name ?? this.name;
    folder.color = color ?? this.color;
    folder.icon = icon ?? this.icon;
    folder.ownerId = ownerId ?? this.ownerId;
    folder.createdAt = createdAt ?? this.createdAt;
    folder.updatedAt = updatedAt ?? this.updatedAt;
    folder.syncStatus = syncStatus ?? this.syncStatus;
    folder.lastSyncedAt = lastSyncedAt ?? this.lastSyncedAt;
    return folder;
  }

  /// Display name (fallback if empty)
  String get displayName => name.isEmpty ? 'Untitled Folder' : name;

  /// Check if folder is synced
  bool get isSynced => syncStatus == 'synced';

  /// Check if folder has sync error
  bool get hasError => syncStatus == 'error';
}
