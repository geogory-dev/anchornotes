import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

/// IsarService
/// Singleton service for managing Isar database operations
/// Handles all CRUD operations for notes in an offline-first manner
class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isar;

  /// Get the Isar instance
  /// Throws an exception if not initialized
  Isar get isar {
    if (_isar == null) {
      throw Exception('IsarService not initialized. Call init() first.');
    }
    return _isar!;
  }

  /// Check if the service is initialized
  bool get isInitialized => _isar != null;

  /// Initialize the Isar database
  /// Must be called before any database operations
  Future<void> init() async {
    if (_isar != null) return; // Already initialized

    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [NoteSchema],
      directory: dir.path,
      name: 'syncpad_db',
    );
  }

  /// Close the database
  /// Should be called when the app is disposed
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  // ==================== CRUD Operations ====================

  /// Create a new note
  /// Returns the ID of the created note
  Future<int> createNote(Note note) async {
    return await isar.writeTxn(() async {
      return await isar.notes.put(note);
    });
  }

  /// Get a note by ID
  /// Returns null if not found
  Future<Note?> getNote(int id) async {
    return await isar.notes.get(id);
  }

  /// Get all notes
  /// Sorted by updatedAt in descending order (most recent first)
  Future<List<Note>> getAllNotes() async {
    return await isar.notes
        .where()
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Update an existing note
  /// Returns the ID of the updated note
  Future<int> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    return await isar.writeTxn(() async {
      return await isar.notes.put(note);
    });
  }

  /// Delete a note by ID
  /// Returns true if deleted, false if not found
  Future<bool> deleteNote(int id) async {
    return await isar.writeTxn(() async {
      return await isar.notes.delete(id);
    });
  }

  /// Delete all notes
  /// Use with caution!
  Future<void> deleteAllNotes() async {
    await isar.writeTxn(() async {
      await isar.notes.clear();
    });
  }

  // ==================== Stream Operations ====================

  /// Watch a specific note for changes
  /// Returns a stream that emits the note whenever it changes
  Stream<Note?> watchNote(int id) {
    return isar.notes.watchObject(id, fireImmediately: true);
  }

  /// Watch all notes for changes
  /// Returns a stream that emits the list of notes whenever any note changes
  Stream<List<Note>> watchAllNotes() {
    return isar.notes
        .where()
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  // ==================== Utility Operations ====================

  /// Get the count of all notes
  Future<int> getNotesCount() async {
    return await isar.notes.count();
  }

  /// Search notes by title or content
  /// Case-insensitive search
  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      return await getAllNotes();
    }

    final allNotes = await getAllNotes();
    final lowerQuery = query.toLowerCase();

    return allNotes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Create initial welcome note if no notes exist
  Future<void> createWelcomeNoteIfNeeded(String userId) async {
    final count = await getNotesCount();
    
    if (count == 0) {
      // Create welcome note
      final welcomeNote = Note()
        ..title = 'Welcome to SyncPad'
        ..content = 'Start writing your thoughts here...\n\nThis is your offline-first note-taking app.'
        ..userId = userId
        ..syncStatus = 'pending';
      
      await createNote(welcomeNote);
    }
  }
}
