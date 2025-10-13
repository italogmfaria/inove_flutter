import 'package:flutter/material.dart';

class CadastroEscolaViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptTerms = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get acceptTerms => _acceptTerms;

  void setAcceptTerms(bool value) {
    // TODO: Implementar lógica
  }

  Future<bool> registerSchool({
    required String nome,
    required String cnpj,
    required String email,
    required String phone,
    required String endereco,
    required String cidade,
    required String estado,
    required String cep,
  }) async {
    // TODO: Implementar lógica de registro da escola
    return false;
  }

  void navigateBack(BuildContext context) {
    // TODO: Implementar navegação
  }
}
