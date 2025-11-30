// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
      );
    });
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return _userFromFirebase(userCredential.user!);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<AppUser> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return _userFromFirebase(userCredential.user!);
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      rethrow;
    }
  }

  Future<AppUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Error signing in with email and password: $e');
      rethrow;
    }
  }

  Future<AppUser> createUserWithEmailAndPassword(
    String email,
    String password,
    {String? displayName}
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user: user is null');
      }
      
      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        try {
          await user.updateDisplayName(displayName);
          await user.reload();
        } catch (e) {
          debugPrint('Warning: Failed to update display name: $e');
          // Continue anyway, account was created successfully
        }
      }
      
      return _userFromFirebase(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException creating user: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error creating user: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  AppUser _userFromFirebase(firebase_auth.User user) {
    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }
}