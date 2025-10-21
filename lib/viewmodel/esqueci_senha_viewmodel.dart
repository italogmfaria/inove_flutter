import 'package:flutter/material.dart';
import '../services/password_recovery_service.dart';
import '../core/utils/validators.dart';
import '../core/utils/helpers.dart';

class EsqueciSenhaViewModel extends ChangeNotifier {
  final PasswordRecoveryService _passwordRecoveryService;

  bool _isLoading = false;
  String? _errorMessage;

  EsqueciSenhaViewModel(this._passwordRecoveryService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? validateEmail(String? value) => Validators.email(value);

  Future<bool> sendRecoveryEmail(String email, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _passwordRecoveryService.requestRecoveryCode(email);
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Código enviado com sucesso para seu e-mail');
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      String message;
      if (e.toString().contains('not_found')) {
        message = 'E-mail não cadastrado';
      } else if (e.toString().contains('already_requested')) {
        message = 'Aguarde alguns minutos antes de solicitar um novo código';
      } else {
        message = 'Não foi possível enviar o código. Tente novamente mais tarde';
      }

      Helpers.showError(context, message);
      return false;
    }
  }

  void navigateToVerifyCode(BuildContext context, String email) {
    Navigator.of(context).pushNamed('/verificar-codigo', arguments: {'email': email});
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
