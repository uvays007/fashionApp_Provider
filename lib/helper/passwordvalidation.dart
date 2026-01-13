String? validatePassword(String password) {
  if (password.length < 6) {
    return "Password must be at least 6 characters";
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return "Password must contain at least one uppercase letter";
  }
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return "Password must contain at least one lowercase letter";
  }
  if (!RegExp(r'\d').hasMatch(password)) {
    return "Password must contain at least one number";
  }
  if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
    return "Password must contain at least one special character";
  }
  return null;
}
