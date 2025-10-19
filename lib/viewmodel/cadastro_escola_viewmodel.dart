import 'package:flutter/material.dart';
import '../services/school_service.dart';
import '../model/school_model.dart';
import '../core/utils/validators.dart';
import '../core/utils/helpers.dart';

class CadastroEscolaViewModel extends ChangeNotifier {
  final SchoolService _schoolService;

  bool _isLoading = false;
  String? _errorMessage;

  CadastroEscolaViewModel(this._schoolService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? validateName(String? value) {
    return Validators.required(value, fieldName: 'Nome da escola');
  }

  String? validateEmail(String? value) {
    return Validators.email(value);
  }

  String? validateCity(String? value) {
    return Validators.required(value, fieldName: 'Cidade');
  }

  String? validateState(String? value) {
    return Validators.required(value, fieldName: 'Estado');
  }

  Future<bool> registerSchool({
    required String nome,
    required String cidade,
    required String email,
    required String federativeUnit,
    required BuildContext context,
  }) async {
    // Validações
    final nameError = validateName(nome);
    if (nameError != null) {
      _errorMessage = nameError;
      notifyListeners();
      Helpers.showError(context, nameError);
      return false;
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      Helpers.showError(context, emailError);
      return false;
    }

    final cityError = validateCity(cidade);
    if (cityError != null) {
      _errorMessage = cityError;
      notifyListeners();
      Helpers.showError(context, cityError);
      return false;
    }

    final stateError = validateState(federativeUnit);
    if (stateError != null) {
      _errorMessage = stateError;
      notifyListeners();
      Helpers.showError(context, stateError);
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final school = SchoolModel(
        name: nome,
        city: cidade,
        email: email,
        federativeUnit: federativeUnit,
      );

      await _schoolService.addSchool(school);

      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Escola cadastrada com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao registrar escola: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
