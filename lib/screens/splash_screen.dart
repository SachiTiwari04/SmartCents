// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:smartcents/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controller (2 seconds total)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade in animation (0 to 1)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Scale animation (0.5 to 1.2 to 1.0) - bounce effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8),
    ));

    // Glow animation (pulsing effect)
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _controller.forward();

    // Navigate after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with glow effect
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withValues(alpha: _glowAnimation.value * 0.6),
                            blurRadius: 60 * _glowAnimation.value,
                            spreadRadius: 20 * _glowAnimation.value,
                          ),
                        ],
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryCyan,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 60,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // App Name
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppTheme.primaryCyan,
                          AppTheme.accentCyan,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'SmartCents',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Tagline
                    Text(
                      'AI-Powered Financial Insights',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary.withValues(alpha: _fadeAnimation.value),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryCyan.withValues(alpha: _glowAnimation.value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}