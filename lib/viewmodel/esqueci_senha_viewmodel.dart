import 'package:flutter/material.dart';

class EsqueciSenhaViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> sendRecoveryEmail(String email) async {
    // TODO: Implementar lógica de recuperação de senha
    return false;
  }

  void navigateToVerifyCode(BuildContext context, String email) {
    // TODO: Implementar navegação
  }

  void navigateBack(BuildContext context) {
    // TODO: Implementar navegação
  }
}
