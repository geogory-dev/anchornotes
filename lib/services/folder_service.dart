import 'package:isar/isar.dart';
import '../models/folder.dart';
import 'isar_service.dart';

/// FolderService
/// Manages folder CRUD operations in local Isar database
class FolderService {
  static final FolderService _instance = FolderService._internal();
  factory FolderService() => _instance;
  FolderService._internal();

  final IsarService _isarService = IsarService();

  /// Get Isar instance
  Isar get isar => _isarService.isar;

  // ==================== CRUD Operations ====================

  /// Create a new folder
  Future<int> createFolder(Folder folder) async {
    return await isar.writeTxn(() async {
      return await isar.folders.put(folder);
    });
  }

  /// Get a folder by local ID
  Future<Folder?> getFolder(int id) async {
    return await isar.folders.get(id);
  }

  /// Get a folder by server ID (Firestore document ID)
  Future<Folder?> getFolderByServerId(String serverId) async {
    return await isar.folders
        .filter()
        .serverIdEqualTo(serverId)
        .findFirst();
  }

  /// Get all folders
  Future<List<Folder>> getAllFolders() async {
    return await isar.folders
        .where()
        .sortByName()
        .findAll();
  }

  /// Watch all folders (real-time updates)
  Stream<List<Folder>> watchAllFolders() {
    return isar.folders
        .where()
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Update an existing folder
  Future<int> updateFolder(Folder folder) async {
    folder.updatedAt = DateTime.now();
    return await isar.writeTxn(() async {
      return await isar.folders.put(folder);
    });
  }

  /// Delete a folder by local ID
  Future<bool> deleteFolder(int id) async {
    return await isar.writeTxn(() async {
      return await isar.folders.delete(id);
    });
  }

  /// Delete a folder by server ID
  Future<bool> deleteFolderByServerId(String serverId) async {
    return await isar.writeTxn(() async {
      final count = await isar.folders
          .filter()
          .serverIdEqualTo(serverId)
          .deleteAll();
      return count > 0;
    });
  }

  /// Delete all folders (for testing/cleanup)
  Future<void> deleteAllFolders() async {
    await isar.writeTxn(() async {
      await isar.folders.clear();
    });
  }

  // ==================== Folder Queries ====================

  /// Get folders by owner ID
  Future<List<Folder>> getFoldersByOwner(String ownerId) async {
    return await isar.folders
        .filter()
        .ownerIdEqualTo(ownerId)
        .sortByName()
        .findAll();
  }

  /// Search folders by name
  Future<List<Folder>> searchFolders(String query) async {
    if (query.isEmpty) return await getAllFolders();

    return await isar.folders
        .filter()
        .nameContains(query, caseSensitive: false)
        .sortByName()
        .findAll();
  }

  /// Get folder with note count
  Future<Folder> getFolderWithNoteCount(int folderId) async {
    final folder = await getFolder(folderId);
    if (folder == null) throw Exception('Folder not found');

    // Count notes in this folder
    final allNotes = await _isarService.getAllNotes();
    final noteCount = allNotes.where((note) => note.folderId == folder.serverId).length;

    folder.noteCount = noteCount;
    return folder;
  }

  /// Get all folders with note counts
  Future<List<Folder>> getAllFoldersWithNoteCounts() async {
    final folders = await getAllFolders();
    final allNotes = await _isarService.getAllNotes();
    
    for (final folder in folders) {
      final noteCount = allNotes.where((note) => note.folderId == folder.folderId).length;
      folder.noteCount = noteCount;
    }
    
    return folders;
  }

  // ==================== Folder Management ====================

  /// Create default folders for new users
  Future<void> createDefaultFolders(String userId) async {
    final defaultFolders = [
      Folder()
        ..name = 'Personal'
        ..icon = '👤'
        ..color = '#2196F3'
        ..ownerId = userId,
      Folder()
        ..name = 'Work'
        ..icon = '💼'
        ..color = '#FF9800'
        ..ownerId = userId,
      Folder()
        ..name = 'Ideas'
        ..icon = '💡'
        ..color = '#4CAF50'
        ..ownerId = userId,
    ];

    for (final folder in defaultFolders) {
      await createFolder(folder);
    }
  }

  /// Check if user has any folders
  Future<bool> hasFolders() async {
    final count = await isar.folders.count();
    return count > 0;
  }

  /// Get folder by name
  Future<Folder?> getFolderByName(String name) async {
    return await isar.folders
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
  }

  // ==================== Utility Methods ====================

  /// Validate folder name
  String? validateFolderName(String name) {
    if (name.trim().isEmpty) {
      return 'Folder name cannot be empty';
    }
    if (name.length > 50) {
      return 'Folder name is too long (max 50 characters)';
    }
    return null;
  }

  /// Get available folder colors
  List<String> getAvailableColors() {
    return [
      '#2196F3', // Blue
      '#FF9800', // Orange
      '#4CAF50', // Green
      '#F44336', // Red
      '#9C27B0', // Purple
      '#00BCD4', // Cyan
      '#FFEB3B', // Yellow
      '#795548', // Brown
      '#607D8B', // Blue Grey
      '#E91E63', // Pink
    ];
  }

  /// Get available folder icons
  List<String> getAvailableIcons() {
    return [
      '📁', '📂', '📋', '📝', '📄',
      '💼', '🏠', '💡', '🎯', '⭐',
      '❤️', '🔥', '✨', '🎨', '📚',
      '🎓', '🏆', '🎮', '🎵', '📷',
    ];
  }
}
