import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/sharing_service.dart';
import '../theme/app_colors.dart';

/// SharingDialog
/// Dialog for managing note collaborators and permissions
class SharingDialog extends StatefulWidget {
  final Note note;

  const SharingDialog({
    super.key,
    required this.note,
  });

  @override
  State<SharingDialog> createState() => _SharingDialogState();
}

class _SharingDialogState extends State<SharingDialog> {
  final SharingService _sharingService = SharingService();
  final TextEditingController _emailController = TextEditingController();
  
  String _selectedPermission = 'editor';
  bool _isLoading = false;
  List<Map<String, dynamic>> _collaborators = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCollaborators();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Load collaborators
  Future<void> _loadCollaborators() async {
    setState(() => _isLoading = true);
    
    try {
      final collaborators = await _sharingService.getCollaborators(widget.note);
      setState(() {
        _collaborators = collaborators;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Share note
  Future<void> _shareNote() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter an email');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _sharingService.shareNoteWithEmail(
        note: widget.note,
        email: email,
        permission: _selectedPermission,
      );

      _emailController.clear();
      await _loadCollaborators();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shared with $email')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Remove collaborator
  Future<void> _removeCollaborator(String userId, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Collaborator'),
        content: Text('Remove $email from this note?'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await _sharingService.unshareNote(
          note: widget.note,
          userId: userId,
        );

        await _loadCollaborators();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Removed $email')),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share Note',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.error,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Only show sharing controls if user is owner
                    if (widget.note.isOwner) ...[
                      // Email input
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          hintText: 'user@example.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Permission dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedPermission,
                        decoration: const InputDecoration(
                          labelText: 'Permission',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'editor',
                            child: Text('Editor - Can edit'),
                          ),
                          DropdownMenuItem(
                            value: 'viewer',
                            child: Text('Viewer - Can only view'),
                          ),
                        ],
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() => _selectedPermission = value!);
                              },
                      ),
                      const SizedBox(height: 16),

                      // Send invite button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _shareNote,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Send Invite'),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Collaborators section
                    Text(
                      'Current Collaborators',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Collaborators list
                    if (_isLoading && _collaborators.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (_collaborators.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No collaborators yet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_collaborators.length, (index) {
                        final collaborator = _collaborators[index];
                        return _buildCollaboratorItem(
                          collaborator['email'],
                          collaborator['permission'],
                          collaborator['userId'],
                          isDark,
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build collaborator item
  Widget _buildCollaboratorItem(
    String email,
    String permission,
    String userId,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                // Permission badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    permission == 'editor' ? 'Editor' : 'Viewer',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.accent,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Remove button (only if owner)
          if (widget.note.isOwner)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.error,
              onPressed: () => _removeCollaborator(userId, email),
            ),
        ],
      ),
    );
  }
}
