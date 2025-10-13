import 'package:flutter/material.dart';

class VerificarCodigoViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String _code = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get code => _code;

  void setCode(String value) {
    // TODO: Implementar lógica
  }

  Future<bool> verifyCode(String email, String code) async {
    // TODO: Implementar lógica de verificação de código
    return false;
  }

  Future<void> resendCode(String email) async {
    // TODO: Implementar lógica de reenvio de código
  }

  void navigateToResetPassword(BuildContext context, String email, String code) {
    // TODO: Implementar navegação
  }

  void navigateBack(BuildContext context) {
    // TODO: Implementar navegação
  }
}
