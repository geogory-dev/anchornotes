import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

/// AuthScreen
/// Unified Login/Register screen with email/password and Google Sign-In
/// Matches the SyncPad design system
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLogin = true; // Toggle between login and register
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle email/password authentication
  Future<void> _handleEmailAuth() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // Sign in
        await _authService.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Sign up
        await _authService.signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      // Navigation handled by AuthGate
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
      // Navigation handled by AuthGate
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Toggle between login and register mode
  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    _buildLogo(isDark),
                    const SizedBox(height: 40),

                    // Heading
                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      _isLogin 
                          ? 'Sign in to continue to your notes'
                          : 'Get started with your note-taking journey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

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
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'your@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      validator: (value) => AuthService.validateEmail(value ?? ''),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !_isLoading,
                      validator: (value) => AuthService.validatePassword(value ?? ''),
                      onFieldSubmitted: (_) => _handleEmailAuth(),
                    ),
                    const SizedBox(height: 24),

                    // Primary button (Login/Register)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_isLogin ? 'Login / Continue' : 'Create Account'),
                    ),
                    const SizedBox(height: 16),

                    // Toggle mode button
                    TextButton(
                      onPressed: _isLoading ? null : _toggleMode,
                      child: Text(
                        _isLogin
                            ? 'Create an Account'
                            : 'Already have an account? Login',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Google Sign-In button
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: Image.asset(
                        'assets/google_logo.png',
                        height: 20,
                        width: 20,
                      ),
                      label: const Text('Sign in with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the AnchorNotes logo
  Widget _buildLogo(bool isDark) {
    return Column(
      children: [
        // Logo icon using launcher icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/launcher_icons/android/ic_launcher.png',
              width: 76,
              height: 76,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Logo text
        Text(
          'AnchorNotes',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        // Tagline
        Text(
          'Your notes, anchored',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
