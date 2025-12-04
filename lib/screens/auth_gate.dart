// lib/screens/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartcents/providers/auth_provider.dart';
import 'package:smartcents/screens/splash_screen.dart';
import 'package:smartcents/screens/main_screen.dart';
import 'package:smartcents/screens/auth/login_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    // After splash, check auth state
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}