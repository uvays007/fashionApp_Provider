import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helper/passwordvalidation.dart';

class SignupProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = false;

  String? usernameError;
  String? emailError;
  String? passwordError;
  bool showPassword = false;

  void togglePasswordVisibility(bool value) {
    showPassword = value;
    notifyListeners();
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    // reset errors
    usernameError = null;
    emailError = null;
    passwordError = null;

    bool hasError = false;

    if (username.trim().isEmpty) {
      usernameError = "Please enter your username";
      hasError = true;
    }
    if (email.trim().isEmpty) {
      emailError = "Please enter your email";
      hasError = true;
    }
    if (password.trim().isEmpty) {
      passwordError = "Please enter your password";
      hasError = true;
    }

    final passwordValidation = validatePassword(password);
    if (passwordValidation != null) {
      passwordError = passwordValidation;
      hasError = true;
    }

    if (hasError) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _db.collection('Users').doc(userCred.user!.uid).set({
        'name': username.trim(),
        'email': email.trim(),
        'uid': userCred.user!.uid,
        'createdAt': Timestamp.now(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emailError = "This email is already registered";
      } else if (e.code == 'invalid-email') {
        emailError = "Invalid email address";
      } else {
        emailError = "Signup failed. Try again.";
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearUsernameError() {
    usernameError = null;
    notifyListeners();
  }

  void clearEmailError() {
    emailError = null;
    notifyListeners();
  }

  void clearPasswordError() {
    passwordError = null;
    notifyListeners();
  }
}
