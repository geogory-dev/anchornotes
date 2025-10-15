import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/isar_service.dart';
import 'screens/auth_gate.dart';
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
      
      // Use AuthGate to manage authentication state
      home: const AuthGate(),
    );
  }
}
