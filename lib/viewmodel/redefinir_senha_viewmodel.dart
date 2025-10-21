import 'package:flutter/material.dart';
import '../services/password_recovery_service.dart';
import '../core/utils/validators.dart';
import '../core/utils/helpers.dart';

class RedefinirSenhaViewModel extends ChangeNotifier {
  final PasswordRecoveryService _passwordRecoveryService;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  RedefinirSenhaViewModel(this._passwordRecoveryService);

  bool get isLoading => _isLoading;
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
    final basicValidation = Validators.password(value);
    if (basicValidation != null) return basicValidation;

    return Validators.passwordStrength(value);
  }

  String? validateConfirmPassword(String password, String? confirmPassword) =>
    Validators.confirmPassword(confirmPassword, password);

  Future<bool> resetPassword(String email, String code, String password, String confirmPassword, BuildContext context) async {
    if (password != confirmPassword) {
      Helpers.showError(context, 'As senhas não coincidem');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _passwordRecoveryService.resetPassword(email, code, password);
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Senha alterada com sucesso! Faça login com sua nova senha');
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      String message;
      if (e.toString().contains('invalid_code')) {
        message = 'Código inválido ou expirado. Solicite um novo código';
      } else if (e.toString().contains('weak_password')) {
        message = 'Escolha uma senha mais forte';
      } else if (e.toString().contains('same_password')) {
        message = 'A nova senha não pode ser igual à anterior';
      } else {
        message = 'Não foi possível alterar sua senha. Tente novamente mais tarde';
      }

      Helpers.showError(context, message);
      return false;
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
