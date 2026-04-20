import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthSessionProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  bool _isAdmin = false; // Track admin status

  AuthSessionProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      // Check if existing session belongs to admin
      _isAdmin = _user?.email == "shajiaimran@gmail.com";
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin; // Getter for the UI

  // Updated Sign In Logic
  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Check if it's the specific admin hardcoded credential
      if (email == "shajiaimran@gmail.com" && password == "shajia1234") {
        _isAdmin = true;
      } else {
        _isAdmin = false;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  // Ensure isAdmin resets on sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _isAdmin = false;
    notifyListeners();
  }

  // Update signUp to ensure new users aren't flagged as admin
  Future<String?> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _isAdmin = false;
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }
}