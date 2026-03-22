import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _profile;
  bool _loading = true;

  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => FirebaseService.isAdmin;

  String get displayName =>
      _profile?['name'] ?? _user?.displayName ?? _user?.email?.split('@').first ?? 'Traveller';

  String get email => _user?.email ?? '';

  String get photoUrl => _user?.photoURL ?? '';

  AuthProvider() {
    FirebaseService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        _profile = await FirebaseService.getUserProfile();
      } else {
        _profile = null;
      }
      _loading = false;
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseService.signIn(email, password);
      _profile = await FirebaseService.getUserProfile();
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      await FirebaseService.signUp(email, password, name);
      _profile = await FirebaseService.getUserProfile();
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> signOut() async {
    await FirebaseService.signOut();
    _profile = null;
    notifyListeners();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await FirebaseService.resetPassword(email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  Future<void> refreshProfile() async {
    _profile = await FirebaseService.getUserProfile();
    notifyListeners();
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password. Please try again.';
      case 'invalid-credential': return 'Invalid email or password.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Check your connection.';
      default: return 'Authentication failed. Please try again.';
    }
  }
}
