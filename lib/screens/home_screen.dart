import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../services/isar_service.dart';
import '../theme/app_colors.dart';
import 'notes_list_screen.dart';

/// HomeScreen
/// Main dashboard after authentication
/// Phase 4: Shows notes list with multi-note management
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

    return NotesListScreen(
      userEmail: authService.userEmail,
      onLogout: () => _handleLogout(context),
    );
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
        // Clear local database before logout
        final IsarService isarService = IsarService();
        final allNotes = await isarService.getAllNotes();
        for (final note in allNotes) {
          await isarService.deleteNote(note.id);
        }
        
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
