import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    // TODO: Implementar lógica
  }

  Future<bool> login(String email, String password) async {
    // TODO: Implementar lógica de login
    return false;
  }

  void navigateToForgotPassword(BuildContext context) {
    // TODO: Implementar navegação
  }

  void navigateToRegister(BuildContext context) {
    // TODO: Implementar navegação
  }
}
