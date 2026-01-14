import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginProvider extends ChangeNotifier {
  String? emailError;
  String? passwordError;
  bool loading = false;
  bool showPassword = false;

  void togglePassword(bool ispassword) {
    showPassword = ispassword;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    emailError = null;
    passwordError = null;

    if (email.trim().isEmpty) {
      emailError = "Please enter your email";
      notifyListeners();
      return false;
    }

    if (password.trim().isEmpty) {
      passwordError = "Please enter your password";
      notifyListeners();
      return false;
    }

    loading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      loading = false;

      switch (e.code) {
        case 'invalid-email':
          emailError = "Invalid email address";
          break;
        case 'user-not-found':
          emailError = "No account found for this email";
          break;
        case 'invalid-credential':
          passwordError = "Password is incorrect";
          break;
        case 'too-many-requests':
          passwordError = "Too many attempts. Try later.";
          break;
        default:
          passwordError = "Login failed. Try again.";
      }

      notifyListeners();
      return false;
    }
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
