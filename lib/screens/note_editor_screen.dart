import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

/// NoteEditorScreen
/// Distraction-free writing interface for creating and editing notes
/// Implements auto-save with debouncing for optimal performance
class NoteEditorScreen extends StatefulWidget {
  final int noteId;

  const NoteEditorScreen({
    super.key,
    required this.noteId,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  Note? _currentNote;
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _isLoading = true;

  // Debounce duration: 2 seconds of inactivity before saving
  static const Duration _debounceDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _loadNote();
    
    // Add listeners for auto-save
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
    
    // Start watching for remote changes
    _watchForRemoteChanges();
  }
  
  /// Watch for remote changes from Firestore
  void _watchForRemoteChanges() {
    // Listen to changes for this specific note
    _isarService.watchNote(widget.noteId).listen((note) {
      if (note != null && mounted) {
        // Only update if the note changed remotely (not from local typing)
        if (note.updatedAt.isAfter(_currentNote?.updatedAt ?? DateTime(2000))) {
          // Check if content is different from what's in the text fields
          if (note.title != _titleController.text || note.content != _contentController.text) {
            setState(() {
              _currentNote = note;
              _titleController.text = note.title;
              _contentController.text = note.content;
            });
            
            // Show a snackbar to notify user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Note updated from another device'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Load the note from the database
  Future<void> _loadNote() async {
    setState(() => _isLoading = true);

    try {
      final note = await _isarService.getNote(widget.noteId);
      
      if (note != null) {
        setState(() {
          _currentNote = note;
          _titleController.text = note.title;
          _contentController.text = note.content;
          _isLoading = false;
        });
      } else {
        // Note not found, navigate back
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Error loading note: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Handle text changes with debouncing
  void _onTextChanged() {
    // Cancel the previous timer
    _debounceTimer?.cancel();

    // Start a new timer
    _debounceTimer = Timer(_debounceDuration, () {
      _saveNote();
    });
  }

  /// Save the note to the database and sync to cloud
  Future<void> _saveNote() async {
    if (_currentNote == null) return;

    setState(() => _isSaving = true);

    try {
      final updatedNote = _currentNote!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        updatedAt: DateTime.now(),
        userId: _authService.userId ?? '',
        syncStatus: 'pending', // Mark as pending sync
      );

      // Save locally first
      await _isarService.updateNote(updatedNote);
      
      setState(() {
        _currentNote = updatedNote;
        _isSaving = false;
      });

      debugPrint('Note saved locally: ${updatedNote.id}');

      // Sync to cloud in background
      _syncService.pushNote(updatedNote).catchError((error) {
        debugPrint('Sync error: $error');
        // Don't show error to user, will retry later
      });
    } catch (e) {
      debugPrint('Error saving note: $e');
      setState(() => _isSaving = false);
    }
  }

  /// Force save before navigating back
  Future<void> _onBackPressed() async {
    // Cancel debounce timer and save immediately
    _debounceTimer?.cancel();
    await _saveNote();
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
        title: Text(
          _currentNote?.displayTitle ?? 'Note',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightTextSecondary
                : AppColors.darkTextSecondary,
          ),
        ),
        actions: [
          // Sync status indicator
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: _buildSyncIndicator(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineLarge,
              decoration: InputDecoration(
                hintText: 'Note Title',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightDivider
                        : AppColors.darkDivider,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            
            // Content Input
            Expanded(
              child: TextField(
                controller: _contentController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the sync status indicator
  Widget _buildSyncIndicator() {
    final syncStatus = _currentNote?.syncStatus ?? 'pending';
    
    if (_isSaving) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).brightness == Brightness.light
                    ? AppColors.accent
                    : AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Saving...',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
        ],
      );
    }

    // Show sync status
    IconData icon;
    Color color;
    String text;

    switch (syncStatus) {
      case 'synced':
        icon = Icons.cloud_done;
        color = AppColors.success;
        text = 'Synced';
        break;
      case 'pending':
        icon = Icons.cloud_queue;
        color = AppColors.accent;
        text = 'Pending';
        break;
      case 'error':
        icon = Icons.cloud_off;
        color = AppColors.error;
        text = 'Offline';
        break;
      default:
        icon = Icons.cloud_queue;
        color = AppColors.accent;
        text = 'Pending';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
