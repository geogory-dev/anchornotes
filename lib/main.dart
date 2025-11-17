import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/isar_service.dart';
import 'services/settings_service.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

/// SyncPad - Offline-First Note-Taking App
/// Phase 1: Single note editor with local database
/// Phase 2: Firebase authentication and user accounts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (only if not already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, ignore error
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }
  
  // Initialize Isar database
  await IsarService().init();
  
  // Initialize settings service
  await SettingsService().init();
  
  runApp(const SyncPadApp());
}

class SyncPadApp extends StatefulWidget {
  const SyncPadApp({super.key});

  @override
  State<SyncPadApp> createState() => _SyncPadAppState();
}

class _SyncPadAppState extends State<SyncPadApp> {
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _settingsService.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {}); // Rebuild app when settings change
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnchorNotes',
      debugShowCheckedModeBanner: false,
      
      // Apply AnchorNotes design system
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _settingsService.themeMode, // Real-time theme
      
      // Define routes
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthGate(),
      },
      
      // Use SplashScreen as initial route
      initialRoute: '/',
    );
  }
}
