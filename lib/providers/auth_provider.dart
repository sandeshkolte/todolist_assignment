import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool loading = false;

  Future login(String email, String password) async {
    loading = true;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future signup(String email, String password) async {
    loading = true;
    notifyListeners();

    try {
      await _authService.signUp(email, password);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future logout() async {
    await _authService.signOut();
  }
}
