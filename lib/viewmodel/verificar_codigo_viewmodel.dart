import 'package:flutter/material.dart';
import '../services/password_recovery_service.dart';
import '../core/utils/validators.dart';
import '../core/utils/helpers.dart';
import '../core/utils/constants.dart';

class VerificarCodigoViewModel extends ChangeNotifier {
  final PasswordRecoveryService _passwordRecoveryService;

  bool _isLoading = false;
  String? _errorMessage;
  String _code = '';

  VerificarCodigoViewModel(this._passwordRecoveryService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get code => _code;

  void setCode(String value) {
    _code = value;
    notifyListeners();
  }

  String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Código é obrigatório';
    }
    if (value.length != Constants.codeLength) {
      return 'O código deve ter ${Constants.codeLength} dígitos';
    }
    return null;
  }

  Future<bool> verifyCode(String email, String code, BuildContext context) async {
    final codeError = validateCode(code);
    if (codeError != null) {
      _errorMessage = codeError;
      notifyListeners();
      Helpers.showError(context, codeError);
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _passwordRecoveryService.verifyRecoveryCode(email, code);
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Código verificado com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Código inválido ou expirado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  Future<void> resendCode(String email, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _passwordRecoveryService.requestRecoveryCode(email);
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Código reenviado com sucesso!');
    } catch (e) {
      _errorMessage = 'Erro ao reenviar código: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
    }
  }

  void navigateToResetPassword(BuildContext context, String email, String code) {
    Navigator.of(context).pushNamed('/redefinir-senha', arguments: {
      'email': email,
      'code': code,
    });
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
