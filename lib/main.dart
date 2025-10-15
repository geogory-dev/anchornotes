import 'package:flutter/material.dart';
import 'services/isar_service.dart';
import 'screens/note_editor_screen.dart';
import 'theme/app_theme.dart';

/// SyncPad - Offline-First Note-Taking App
/// Phase 1: Single note editor with local database
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar database
  await IsarService().init();
  
  runApp(const SyncPadApp());
}

class SyncPadApp extends StatelessWidget {
  const SyncPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncPad',
      debugShowCheckedModeBanner: false,
      
      // Apply SyncPad design system
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme
      
      home: const SplashScreen(),
    );
  }
}

/// Splash Screen
/// Loads the default note and navigates to the editor
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final IsarService _isarService = IsarService();

  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  /// Load the default note and navigate to the editor
  Future<void> _loadAndNavigate() async {
    // Ensure database is initialized
    if (!_isarService.isInitialized) {
      await _isarService.init();
    }

    // Get or create the default note (ID: 1)
    final note = await _isarService.getOrCreateDefaultNote();

    // Navigate to the editor
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(noteId: note.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
