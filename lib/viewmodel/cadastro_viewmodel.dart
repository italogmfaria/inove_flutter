import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/school_service.dart';
import '../model/school_model.dart';
import '../core/utils/validators.dart';
import '../core/utils/helpers.dart';

class CadastroViewModel extends ChangeNotifier {
  final UserService _userService;
  final SchoolService _schoolService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  List<SchoolModel> _schools = [];
  int? _selectedSchoolId;

  CadastroViewModel(this._userService, this._schoolService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  List<SchoolModel> get schools => _schools;
  int? get selectedSchoolId => _selectedSchoolId;

  String _getErrorMessage(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('already exists') ||
        errorMessage.contains('duplicate') ||
        errorMessage.contains('409')) {
      if (errorMessage.contains('email')) {
        return 'Este e-mail já está cadastrado';
      }
      if (errorMessage.contains('cpf')) {
        return 'Este CPF já está cadastrado';
      }
      return 'Usuário já cadastrado no sistema';
    }

    if (errorMessage.contains('timeout') ||
        errorMessage.contains('connection failed')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente';
    }

    if (errorMessage.contains('invalid') ||
        errorMessage.contains('validation')) {
      if (errorMessage.contains('cpf')) {
        return 'CPF inválido';
      }
      if (errorMessage.contains('email')) {
        return 'E-mail inválido';
      }
      if (errorMessage.contains('password')) {
        return 'A senha não atende aos requisitos mínimos';
      }
    }

    if (errorMessage.contains('school') &&
        errorMessage.contains('not found')) {
      return 'Escola não encontrada. Por favor, selecione uma escola válida';
    }

    return 'Ocorreu um erro ao realizar o cadastro. Tente novamente mais tarde';
  }

  Future<void> loadSchools(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      _schools = await _schoolService.getSchools();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
    }
  }

  void setSelectedSchool(int? schoolId) {
    _selectedSchoolId = schoolId;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Validações
  String? validateName(String? value) {
    return Validators.required(value, fieldName: 'Nome');
  }

  String? validateEmail(String? value) {
    return Validators.email(value);
  }

  String? validatePassword(String? value) {
    final passwordError = Validators.password(value);
    if (passwordError != null) return passwordError;
    return Validators.passwordStrength(value);
  }

  String? validateCpf(String? value) {
    return Validators.cpf(value);
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String cpf,
    required DateTime birthDate,
    required SchoolModel school,
    required BuildContext context,
  }) async {
    // Validações
    final nameError = validateName(name);
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

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      _errorMessage = passwordError;
      notifyListeners();
      Helpers.showError(context, passwordError);
      return false;
    }

    final cpfError = validateCpf(cpf);
    if (cpfError != null) {
      _errorMessage = cpfError;
      notifyListeners();
      Helpers.showError(context, cpfError);
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.registerStudent({
        'name': name,
        'email': email,
        'password': password,
        'cpf': cpf,
        'birthDate': birthDate.toIso8601String(),
        'school': school.toJson(),
      });
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Cadastro realizado com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void navigateToSchoolRegister(BuildContext context) {
    Navigator.of(context).pushNamed('/cadastro-escola');
  }
}
