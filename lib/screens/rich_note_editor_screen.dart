import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../models/note.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import 'sharing_dialog.dart';

/// RichNoteEditorScreen
/// Rich text editor with formatting toolbar
class RichNoteEditorScreen extends StatefulWidget {
  final int noteId;

  const RichNoteEditorScreen({
    super.key,
    required this.noteId,
  });

  @override
  State<RichNoteEditorScreen> createState() => _RichNoteEditorScreenState();
}

class _RichNoteEditorScreenState extends State<RichNoteEditorScreen> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  final ExportService _exportService = ExportService();
  final TextEditingController _titleController = TextEditingController();
  
  quill.QuillController? _quillController;
  Note? _currentNote;
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _isLoading = true;
  bool _showToolbar = true;

  static const Duration _debounceDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _loadNote();
    _titleController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _quillController?.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    try {
      final note = await _isarService.getNote(widget.noteId);
      if (note != null && mounted) {
        setState(() {
          _currentNote = note;
          _titleController.text = note.title;
          
          // Load content into Quill
          if (note.content.isNotEmpty) {
            try {
              // Try to parse as JSON (rich text)
              final doc = quill.Document.fromJson(jsonDecode(note.content));
              _quillController = quill.QuillController(
                document: doc,
                selection: const TextSelection.collapsed(offset: 0),
              );
            } catch (e) {
              // If not JSON, treat as plain text
              _quillController = quill.QuillController.basic();
              _quillController!.document.insert(0, note.content);
            }
          } else {
            _quillController = quill.QuillController.basic();
          }
          
          _quillController!.addListener(_onTextChanged);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading note: $e')),
        );
      }
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, _saveNote);
  }

  Future<void> _saveNote() async {
    if (_currentNote == null || _quillController == null) return;

    setState(() => _isSaving = true);

    try {
      // Convert Quill document to JSON
      final delta = _quillController!.document.toDelta();
      final jsonContent = jsonEncode(delta.toJson());

      final updatedNote = _currentNote!.copyWith(
        title: _titleController.text,
        content: jsonContent,
      );

      await _isarService.updateNote(updatedNote);
      await _syncService.pushNote(updatedNote);

      setState(() {
        _currentNote = updatedNote;
        _isSaving = false;
      });
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSaving
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Saving...', style: TextStyle(fontSize: 16)),
                ],
              )
            : const Text('Edit Note'),
        actions: [
          // More menu with all options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) async {
              switch (value) {
                case 'share':
                  if (_currentNote != null) {
                    showDialog(
                      context: context,
                      builder: (context) => SharingDialog(note: _currentNote!),
                    );
                  }
                  break;
                case 'info':
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Rich Text Sync Info'),
                      content: const Text(
                        'Rich text formatting uses "Last Write Wins" sync.\n\n'
                        '⚠️ If multiple people edit the same note offline, '
                        'the last person to sync will overwrite others\' changes.\n\n'
                        '💡 For best results:\n'
                        '• Edit notes one at a time\n'
                        '• Stay online when collaborating\n'
                        '• Check "Last edited" timestamp before editing',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  );
                  break;
                case 'toolbar':
                  setState(() => _showToolbar = !_showToolbar);
                  break;
                case 'save':
                  await _saveNote();
                  break;
                case 'pdf':
                  if (_currentNote != null) {
                    await _saveNote();
                    await _exportService.exportToPdf(_currentNote!, context);
                  }
                  break;
                case 'markdown':
                  if (_currentNote != null) {
                    await _saveNote();
                    await _exportService.exportToMarkdown(_currentNote!, context);
                  }
                  break;
                case 'text':
                  if (_currentNote != null) {
                    await _saveNote();
                    await _exportService.exportAsText(_currentNote!, context);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              // Share with collaborators (only if owner)
              if ((_currentNote?.isOwner ?? false) || 
                  (_currentNote?.ownerId == _authService.userId))
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 8),
                      Text('Share with others'),
                    ],
                  ),
                ),
              // Toggle toolbar
              PopupMenuItem(
                value: 'toolbar',
                child: Row(
                  children: [
                    Icon(_showToolbar ? Icons.keyboard_hide : Icons.keyboard),
                    const SizedBox(width: 8),
                    Text(_showToolbar ? 'Hide Toolbar' : 'Show Toolbar'),
                  ],
                ),
              ),
              // Save
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Save Now'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              // Export options
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'markdown',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Export as Markdown'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'text',
                child: Row(
                  children: [
                    Icon(Icons.text_fields),
                    SizedBox(width: 8),
                    Text('Export as Text'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              // Info
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Sync Info'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              decoration: InputDecoration(
                hintText: 'Note Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          
          // Rich text toolbar
          if (_showToolbar && _quillController != null)
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: quill.QuillToolbar.simple(
                  configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: _quillController!,
                    showAlignmentButtons: true,
                    showBackgroundColorButton: true,
                    showBoldButton: true,
                    showCenterAlignment: true,
                    showClearFormat: true,
                    showCodeBlock: true,
                    showColorButton: true,
                    showDirection: false,
                    showDividers: true,
                    showFontFamily: false,
                    showFontSize: true,
                    showHeaderStyle: true,
                    showIndent: true,
                    showInlineCode: true,
                    showItalicButton: true,
                    showJustifyAlignment: true,
                    showLeftAlignment: true,
                    showLink: true,
                    showListBullets: true,
                    showListCheck: true,
                    showListNumbers: true,
                    showQuote: true,
                    showRedo: true,
                    showRightAlignment: true,
                    showSearchButton: false,
                    showSmallButton: false,
                    showStrikeThrough: true,
                    showSubscript: false,
                    showSuperscript: false,
                    showUnderLineButton: true,
                    showUndo: true,
                  ),
                ),
              ),
            ),
          
          // Rich text editor
          Expanded(
            child: _quillController == null
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    padding: const EdgeInsets.all(16),
                    child: quill.QuillEditor.basic(
                      configurations: quill.QuillEditorConfigurations(
                        controller: _quillController!,
                        readOnly: false,
                        placeholder: 'Start writing...',
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
          ),
          
          // Last edited timestamp
          if (_currentNote != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last edited: ${_formatTimestamp(_currentNote!.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                  ),
                  if (_currentNote!.isShared)
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Shared',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
