import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/utils/validators.dart';
import '../core/utils/helpers.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  LoginViewModel(this._authService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    return Validators.email(value);
  }

  String? validatePassword(String? value) {
    return Validators.password(value);
  }

  Future<bool> login(String email, String password, BuildContext context) async {
    // Validação antes de enviar
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      Helpers.showError(context, emailError);
      return false;
    }

    if (passwordError != null) {
      _errorMessage = passwordError;
      notifyListeners();
      Helpers.showError(context, passwordError);
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Login realizado com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao fazer login: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  void navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed('/esqueci-senha');
  }

  void navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed('/cadastro');
  }
}
