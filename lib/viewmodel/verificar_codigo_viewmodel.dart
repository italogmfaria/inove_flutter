import 'package:flutter/material.dart';
import '../services/password_recovery_service.dart';
import '../core/utils/helpers.dart';
import '../core/utils/validators.dart';

class VerificarCodigoViewModel extends ChangeNotifier {
  final PasswordRecoveryService _passwordRecoveryService;
  bool _isLoading = false;

  VerificarCodigoViewModel(this._passwordRecoveryService);

  bool get isLoading => _isLoading;

  String? validateCode(String? value) => Validators.code(value);
  String? validateEmail(String? value) => Validators.email(value);

  Future<bool> verifyCode(String email, String code, BuildContext context) async {
    // Validação dos dados antes de chamar a API
    final emailError = validateEmail(email);
    if (emailError != null) {
      Helpers.showError(context, emailError);
      return false;
    }

    final codeError = validateCode(code);
    if (codeError != null) {
      Helpers.showError(context, codeError);
      return false;
    }

    try {
      _setLoading(true);
      await _passwordRecoveryService.verifyRecoveryCode(email, code);
      return true;
    } catch (e) {
      String message;
      if (e.toString().contains('invalid_code')) {
        message = 'Código inválido. Verifique e tente novamente';
      } else if (e.toString().contains('code_expired')) {
        message = 'Código expirado. Solicite um novo código';
      } else if (e.toString().contains('too_many_attempts')) {
        message = 'Muitas tentativas inválidas. Aguarde alguns minutos';
      } else {
        message = 'Erro ao verificar o código. Tente novamente mais tarde';
      }

      Helpers.showError(context, message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendCode(String email, BuildContext context) async {
    // Validação do email antes de reenviar
    final emailError = validateEmail(email);
    if (emailError != null) {
      Helpers.showError(context, emailError);
      return false;
    }

    try {
      _setLoading(true);
      await _passwordRecoveryService.requestRecoveryCode(email);
      Helpers.showSuccess(context, 'Novo código enviado para seu e-mail');
      return true;
    } catch (e) {
      String message;
      if (e.toString().contains('already_requested')) {
        message = 'Aguarde alguns minutos antes de solicitar um novo código';
      } else {
        message = 'Não foi possível enviar um novo código. Tente novamente mais tarde';
      }

      Helpers.showError(context, message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void navigateToResetPassword(BuildContext context, String email, String code) {
    Navigator.of(context).pushNamed(
      '/redefinir-senha',
      arguments: {'email': email, 'code': code},
    );
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
