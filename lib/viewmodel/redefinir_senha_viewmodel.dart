import 'package:flutter/material.dart';
import '../services/password_recovery_service.dart';
import '../core/utils/validators.dart';
import '../core/utils/helpers.dart';

class RedefinirSenhaViewModel extends ChangeNotifier {
  final PasswordRecoveryService _passwordRecoveryService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  RedefinirSenhaViewModel(this._passwordRecoveryService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  String? validatePassword(String? value) {
    final passwordError = Validators.password(value);
    if (passwordError != null) return passwordError;
    return Validators.passwordStrength(value);
  }

  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (password != confirmPassword) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
    String confirmPassword,
    BuildContext context,
  ) async {
    final passwordError = validatePassword(newPassword);
    if (passwordError != null) {
      _errorMessage = passwordError;
      notifyListeners();
      Helpers.showError(context, passwordError);
      return false;
    }

    final confirmPasswordError = validateConfirmPassword(newPassword, confirmPassword);
    if (confirmPasswordError != null) {
      _errorMessage = confirmPasswordError;
      notifyListeners();
      Helpers.showError(context, confirmPasswordError);
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _passwordRecoveryService.resetPassword(email, code, newPassword);
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Senha redefinida com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao redefinir senha: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
