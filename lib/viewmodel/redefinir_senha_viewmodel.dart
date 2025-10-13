import 'package:flutter/material.dart';

class RedefinirSenhaViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void togglePasswordVisibility() {
    // TODO: Implementar lógica
  }

  void toggleConfirmPasswordVisibility() {
    // TODO: Implementar lógica
  }

  Future<bool> resetPassword(String email, String code, String newPassword) async {
    // TODO: Implementar lógica de redefinição de senha
    return false;
  }

  void navigateToLogin(BuildContext context) {
    // TODO: Implementar navegação
  }
}
