import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'note_editor_screen.dart';

/// NotesListScreen
/// Displays all notes in a grid/list view with real-time updates
/// Phase 4: Multi-note management
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Create a new note
  Future<void> _createNewNote() async {
    final newNote = Note()
      ..title = ''
      ..content = ''
      ..userId = _authService.userId ?? ''
      ..syncStatus = 'pending';

    final noteId = await _isarService.createNote(newNote);
    
    // Sync to cloud
    final createdNote = await _isarService.getNote(noteId);
    if (createdNote != null) {
      await _syncService.pushNote(createdNote);
    }

    // Navigate to editor
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(noteId: noteId),
        ),
      );
    }
  }

  /// Delete a note
  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.displayTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _syncService.deleteNote(note.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    }
  }

  /// Manual sync
  Future<void> _refreshNotes() async {
    setState(() => _isRefreshing = true);
    
    try {
      await _syncService.syncAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync error: $e')),
        );
      }
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  /// Filter notes by search query
  List<Note> _filterNotes(List<Note> notes) {
    if (_searchQuery.isEmpty) return notes;
    
    final query = _searchQuery.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
             note.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncPad'),
        actions: [
          // Sync status
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(_getSyncIcon()),
              onPressed: _refreshNotes,
              tooltip: 'Sync',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Notes list
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _isarService.watchAllNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allNotes = snapshot.data ?? [];
                final notes = _filterNotes(allNotes);

                if (notes.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _refreshNotes,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return _buildNoteCard(notes[index], isDark);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build note card
  Widget _buildNoteCard(Note note, bool isDark) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(noteId: note.id),
            ),
          );
        },
        onLongPress: () => _deleteNote(note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                note.displayTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Preview
              Expanded(
                child: Text(
                  note.preview,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timestamp
                  Text(
                    _formatTimestamp(note.updatedAt),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),

                  // Sync status
                  Icon(
                    _getNoteStatusIcon(note),
                    size: 16,
                    color: _getNoteStatusColor(note),
                  ),
                ],
              ),

              // Shared indicator
              if (note.isShared)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Shared',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.accent,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 80,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightTextSecondary
                : AppColors.darkTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No notes yet' : 'No notes found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Tap + to create your first note'
                : 'Try a different search',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// Get sync icon
  IconData _getSyncIcon() {
    switch (_syncService.syncStatus) {
      case 'synced':
        return Icons.cloud_done;
      case 'syncing':
        return Icons.sync;
      case 'error':
        return Icons.cloud_off;
      default:
        return Icons.cloud_queue;
    }
  }

  /// Get note status icon
  IconData _getNoteStatusIcon(Note note) {
    switch (note.syncStatus) {
      case 'synced':
        return Icons.cloud_done;
      case 'pending':
        return Icons.cloud_queue;
      case 'error':
        return Icons.cloud_off;
      default:
        return Icons.cloud_queue;
    }
  }

  /// Get note status color
  Color _getNoteStatusColor(Note note) {
    switch (note.syncStatus) {
      case 'synced':
        return AppColors.success;
      case 'pending':
        return AppColors.accent;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.accent;
    }
  }

  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
