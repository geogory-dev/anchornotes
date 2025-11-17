import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _animationController.forward();

    // Navigate to auth gate after 3 seconds
    _navigateToAuthGate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToAuthGate() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flutter logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: CustomFlutterLogo(size: 80),
                ),
              ),
              const SizedBox(height: 24),
              // App name
              const Text(
                'AnchorNotes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02569B),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Your notes, anchored',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomFlutterLogo extends StatelessWidget {
  final double size;

  const CustomFlutterLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Left wing
          Positioned(
            left: 0,
            top: size * 0.3,
            child: Container(
              width: size * 0.4,
              height: size * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xFF02569B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Right wing
          Positioned(
            right: 0,
            top: size * 0.3,
            child: Container(
              width: size * 0.4,
              height: size * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xFF0175C2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Center bar
          Positioned(
            left: size * 0.2,
            top: size * 0.45,
            child: Container(
              width: size * 0.6,
              height: size * 0.1,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF02569B), Color(0xFF0175C2)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
