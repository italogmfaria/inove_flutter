import 'package:flutter/material.dart';

class CadastroViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get acceptTerms => _acceptTerms;

  void togglePasswordVisibility() {
    // TODO: Implementar lógica
  }

  void toggleConfirmPasswordVisibility() {
    // TODO: Implementar lógica
  }

  void setAcceptTerms(bool value) {
    // TODO: Implementar lógica
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String cpf,
  }) async {
    // TODO: Implementar lógica de registro
    return false;
  }

  void navigateToLogin(BuildContext context) {
    // TODO: Implementar navegação
  }

  void navigateToSchoolRegister(BuildContext context) {
    // TODO: Implementar navegação
  }
}
