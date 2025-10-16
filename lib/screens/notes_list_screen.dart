import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/error_banner.dart';
import '../widgets/folder_picker.dart';
import 'rich_note_editor_screen.dart';
import 'folders_screen.dart';

/// NotesListScreen
/// Displays all notes in a grid/list view with real-time updates
/// Phase 4: Multi-note management
class NotesListScreen extends StatefulWidget {
  final String? userEmail;
  final VoidCallback? onLogout;

  const NotesListScreen({
    super.key,
    this.userEmail,
    this.onLogout,
  });

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
  bool _showOnlyFavorites = false;

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
      ..ownerId = _authService.userId ?? ''
      ..permission = 'owner'
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
          builder: (context) => RichNoteEditorScreen(noteId: noteId),
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
      try {
        await _syncService.deleteNote(note.id);
        
        if (mounted) {
          SuccessSnackBar.show(context, 'Note deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            'Failed to delete note: ${_syncService.getErrorMessage(e)}',
            onRetry: () => _deleteNote(note),
          );
        }
      }
    }
  }

  /// Manual sync
  Future<void> _refreshNotes() async {
    setState(() => _isRefreshing = true);
    
    try {
      await _syncService.syncAll();
      if (mounted) {
        SuccessSnackBar.show(context, 'Notes synced successfully');
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          _syncService.getErrorMessage(e),
          onRetry: _refreshNotes,
        );
      }
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  /// Filter notes by search query and favorites
  List<Note> _filterNotes(List<Note> notes) {
    var filtered = notes;
    
    // Filter by favorites first
    if (_showOnlyFavorites) {
      filtered = filtered.where((note) => note.isFavorite).toList();
    }
    
    // Then filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(query) ||
               note.content.toLowerCase().contains(query);
      }).toList();
    }
    
    // Sort: favorites first, then by date
    filtered.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    
    return filtered;
  }

  /// Move note to folder
  Future<void> _moveNoteToFolder(Note note) async {
    final result = await showDialog(
      context: context,
      builder: (context) => FolderPicker(
        currentFolderId: note.folderId,
      ),
    );

    // Check if user canceled or selected a folder
    if (result != null && result is FolderSelection && !result.wasCanceled) {
      try {
        final updatedNote = note.copyWith(
          folderId: result.folder?.folderId,
          folderName: result.folder?.name ?? '',
        );
        
        // Update local database
        await _isarService.updateNote(updatedNote);
        
        // Trigger sync
        await _syncService.pushNote(updatedNote);
        
        if (mounted) {
          SuccessSnackBar.show(
            context,
            result.folder == null ? 'Moved to No Folder' : 'Moved to ${result.folder!.name}',
          );
        }
      } catch (e) {
        if (mounted) {
          ErrorSnackBar.show(context, 'Failed to move note: $e');
        }
      }
    }
  }

  /// Toggle favorite status
  Future<void> _toggleFavorite(Note note) async {
    try {
      final updatedNote = note.copyWith(isFavorite: !note.isFavorite);
      
      // Update local database
      await _isarService.updateNote(updatedNote);
      
      // Trigger sync
      await _syncService.pushNote(updatedNote);
      
      if (mounted) {
        SuccessSnackBar.show(
          context,
          updatedNote.isFavorite ? 'Added to favorites' : 'Removed from favorites',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, 'Failed to update favorite: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AnchorNotes'),
        actions: [
          // Sync status indicator
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
              icon: const Icon(Icons.refresh),
              onPressed: _refreshNotes,
              tooltip: 'Refresh',
            ),
        ],
      ),
      drawer: _buildDrawer(context, isDark),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Notes grid
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _isarService.watchAllNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final allNotes = snapshot.data ?? [];
                final filteredNotes = _filterNotes(allNotes);

                if (filteredNotes.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    return _buildNoteCard(filteredNotes[index], isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build navigation drawer
  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.note_alt, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'AnchorNotes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.userEmail != null)
                  Text(
                    widget.userEmail!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          // All Notes
          ListTile(
            leading: Icon(
              _showOnlyFavorites ? Icons.note_outlined : Icons.note,
              color: !_showOnlyFavorites ? AppColors.lightPrimary : null,
            ),
            title: const Text('All Notes'),
            onTap: () {
              setState(() => _showOnlyFavorites = false);
              Navigator.pop(context);
            },
          ),
          // Favorites
          ListTile(
            leading: Icon(
              Icons.star,
              color: _showOnlyFavorites ? Colors.amber : null,
            ),
            title: const Text('Favorites'),
            onTap: () {
              setState(() => _showOnlyFavorites = true);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          // Folders
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Folders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FoldersScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // Settings (placeholder)
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              widget.onLogout?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showOnlyFavorites ? Icons.star_border : Icons.note_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _showOnlyFavorites ? 'No favorite notes yet' : 'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _showOnlyFavorites
                ? 'Star some notes to see them here'
                : 'Tap + to create your first note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  /// Build note card with Hero animation
  Widget _buildNoteCard(Note note, bool isDark) {
    return Hero(
      tag: 'note_${note.id}',
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    RichNoteEditorScreen(noteId: note.id),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.1);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  
                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
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
                // Title with menu button
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (note.isFavorite)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              note.displayTitle,
                              style: Theme.of(context).textTheme.headlineMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'move') {
                          _moveNoteToFolder(note);
                        } else if (value == 'delete') {
                          _deleteNote(note);
                        } else if (value == 'favorite') {
                          _toggleFavorite(note);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(note.isFavorite ? Icons.star : Icons.star_border),
                              const SizedBox(width: 8),
                              Text(note.isFavorite ? 'Unfavorite' : 'Favorite'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'move',
                          child: Row(
                            children: [
                              Icon(Icons.folder),
                              SizedBox(width: 8),
                              Text('Move to Folder'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
      ),
    );
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
