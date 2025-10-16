import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'isar_service.dart';

/// AuthService
/// Handles all Firebase Authentication operations
/// Supports email/password and Google Sign-In
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Store user email in Firestore for sharing
  Future<void> _storeUserEmail(String userId, String email) async {
    try {
      debugPrint('AuthService: Storing email $email for user $userId');
      await _firestore.collection('users').doc(userId).set({
        'email': email.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('AuthService: Email stored successfully');
      
      // Verify
      final doc = await _firestore.collection('users').doc(userId).get();
      debugPrint('AuthService: Verified - doc exists: ${doc.exists}, data: ${doc.data()}');
    } catch (e) {
      debugPrint('AuthService: Error storing email: $e');
      debugPrint('AuthService: Error details: ${e.runtimeType}');
    }
  }

  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user ID
  String? get userId => currentUser?.uid;

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== Email/Password Authentication ====================

  /// Sign up with email and password
  /// Returns the User object on success, throws exception on failure
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // Ensure clean state: sign out any existing user first
    if (_auth.currentUser != null) {
      debugPrint('AuthService: Existing user detected. Signing out before signup.');
      await signOut();
    }
    
    UserCredential? credential;
    try {
      debugPrint('AuthService: Starting signup for $email');
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      debugPrint('AuthService: Signup successful, user ID: ${credential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Signup error: $e');
      // Ignore the type cast error, user is still created
    }
    
    // Get the current user (workaround for type cast issue)
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint('AuthService: Got current user: ${user.uid}');
      // Store user email for sharing functionality
      try {
        await _storeUserEmail(user.uid, email.trim());
      } catch (e) {
        debugPrint('AuthService: Failed to store email: $e');
      }
    }
    
    return user;
  }

  /// Sign in with email and password
  /// Returns the User object on success, throws exception on failure
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Ensure clean state: sign out any existing user first
    if (_auth.currentUser != null) {
      debugPrint('AuthService: Existing user detected. Signing out before signin.');
      await signOut();
    }
    
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Store user email for sharing functionality (in case it wasn't stored during signup)
      if (credential.user != null) {
        await _storeUserEmail(credential.user!.uid, email.trim());
      }
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // ==================== Google Sign-In ====================

  /// Sign in with Google
  /// Returns the User object on success, throws exception on failure
  Future<User?> signInWithGoogle() async {
    // Ensure clean state: sign out any existing user first
    if (_auth.currentUser != null) {
      debugPrint('AuthService: Existing user detected. Signing out before Google signin.');
      await signOut();
    }
    
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Store user email for sharing functionality
      if (userCredential.user != null && userCredential.user!.email != null) {
        await _storeUserEmail(userCredential.user!.uid, userCredential.user!.email!);
      }
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to sign in with Google. Please try again.';
    }
  }

  // ==================== Password Reset ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // ==================== Sign Out ====================

  /// Clear local database
  /// Prevents data leakage between accounts
  Future<void> _clearLocalData() async {
    try {
      final isarService = IsarService();
      if (isarService.isInitialized) {
        await isarService.deleteAllNotes();
        debugPrint('AuthService: Cleared local database');
      }
    } catch (e) {
      debugPrint('AuthService: Error clearing local data: $e');
    }
  }

  /// Sign out from Firebase and Google
  /// Also clears local database to prevent data leakage between accounts
  Future<void> signOut() async {
    try {
      // Clear local database before signing out
      await _clearLocalData();
      
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // ==================== Account Management ====================

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Please sign in again before deleting your account.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await currentUser?.updateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to update email. Please try again.';
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to update password. Please try again.';
    }
  }

  // ==================== Error Handling ====================

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // ==================== Validation Helpers ====================

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate password strength
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate email
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}
