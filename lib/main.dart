import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'screens/auth_gate.dart';
import 'firebase_options.dart';

/// Main entry point of the SmartCents application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase ONCE using firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  debugPrint('✅ Firebase initialized successfully');
  
  runApp(const ProviderScope(child: SmartCentsApp()));
}

/// Root widget of the SmartCents application
class SmartCentsApp extends StatelessWidget {
  const SmartCentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCents',
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}