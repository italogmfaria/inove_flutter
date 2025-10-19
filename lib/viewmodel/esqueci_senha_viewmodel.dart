import 'package:flutter/material.dart';
import '../services/password_recovery_service.dart';
import '../core/utils/validators.dart';
import '../core/utils/helpers.dart';

class EsqueciSenhaViewModel extends ChangeNotifier {
  final PasswordRecoveryService _passwordRecoveryService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  EsqueciSenhaViewModel(this._passwordRecoveryService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  String? validateEmail(String? value) {
    return Validators.email(value);
  }

  Future<bool> sendRecoveryEmail(String email, BuildContext context) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      Helpers.showError(context, emailError);
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _passwordRecoveryService.requestRecoveryCode(email);
      _successMessage = 'Código de recuperação enviado para seu e-mail';
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, _successMessage!);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao enviar e-mail: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  void navigateToVerifyCode(BuildContext context, String email) {
    Navigator.of(context).pushNamed('/verificar-codigo', arguments: email);
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
