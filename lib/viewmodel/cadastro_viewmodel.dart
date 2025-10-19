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

  Future<void> loadSchools() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schools = await _schoolService.getSchools();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar escolas: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
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
    required int schoolId,
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
        'schoolId': schoolId,
      });
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Cadastro realizado com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao registrar: ${e.toString()}';
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
