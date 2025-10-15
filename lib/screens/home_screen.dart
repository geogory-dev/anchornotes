import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';
import '../theme/app_colors.dart';
import 'note_editor_screen.dart';

/// HomeScreen
/// Main dashboard after authentication
/// Phase 2: Simple screen with logout and access to the note editor
/// Phase 3: Added cloud sync initialization
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SyncService _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    // Initialize sync service when home screen loads
    _syncService.initialize();
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final IsarService isarService = IsarService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncPad'),
        actions: [
          // User info
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                authService.userEmail ?? 'User',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
              ),
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Text(
                'Welcome to SyncPad!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You are now signed in',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Open note editor button
              ElevatedButton.icon(
                onPressed: () => _openNoteEditor(context, isarService),
                icon: const Icon(Icons.edit_note),
                label: const Text('Open Note Editor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info text
              Text(
                'Phase 2: Authentication Complete\nPhase 3 will add notes list',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Open the note editor with the default note
  Future<void> _openNoteEditor(BuildContext context, IsarService isarService) async {
    // Get or create the default note
    final note = await isarService.getOrCreateDefaultNote();

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(noteId: note.id),
        ),
      );
    }
  }

  /// Handle logout
  Future<void> _handleLogout(BuildContext context) async {
    final AuthService authService = AuthService();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await authService.signOut();
        // Navigation handled by AuthGate
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
