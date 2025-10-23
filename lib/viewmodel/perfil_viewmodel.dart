import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/school_model.dart';
import '../model/course_model.dart';
import '../services/user_service.dart';
import '../services/school_service.dart';
import '../services/auth_service.dart';
import '../core/utils/helpers.dart';
import '../core/utils/validators.dart';

class PerfilViewModel extends ChangeNotifier {
  final UserService _userService;
  final SchoolService _schoolService;
  final AuthService _authService;

  UserModel? _user;
  SchoolModel? _school;
  List<CursoModel> _myCourses = [];
  bool _isLoading = false;
  bool _isLoadingCourses = false;
  String? _errorMessage;
  bool _isEditing = false;

  PerfilViewModel(this._userService, this._schoolService, this._authService);

  UserModel? get user => _user;
  SchoolModel? get school => _school;
  List<CursoModel> get myCourses => _myCourses;
  bool get isLoading => _isLoading;
  bool get isLoadingCourses => _isLoadingCourses;
  String? get errorMessage => _errorMessage;
  bool get isEditing => _isEditing;

  void setEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  Future<void> loadProfile({BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.getMyProfile();

      // Carregar dados da escola se o usuário tiver uma
      if (_user?.schoolId != null) {
        try {
          _school = await _schoolService.getMySchool();
        } catch (e) {
          print('Erro ao carregar escola: ${e.toString()}');
        }
      }

      // Carregar cursos do usuário
      await loadMyCourses();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar perfil: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (context != null) {
        Helpers.showError(context, _errorMessage!);
      }
    }
  }

  Future<void> loadMyCourses() async {
    _isLoadingCourses = true;
    notifyListeners();

    try {
      _myCourses = await _userService.getMyCourses();
      _isLoadingCourses = false;
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar cursos: ${e.toString()}');
      _myCourses = [];
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  // TODO: Quando o backend estiver pronto, substitua este valor pelo progresso real do usuário
  double getCourseProgress(CursoModel curso) {
    // Valor padrão temporário: varia entre 20% e 75%
    // Futuramente, este valor virá do backend
    final progressMap = {
      0: 0.75, // 75%
      1: 0.40, // 40%
      2: 0.20, // 20%
    };

    // Usa o ID do curso ou índice para variar o progresso
    final index = curso.id != null ? curso.id! % 3 : 0;
    return progressMap[index] ?? 0.30;
  }


  String? validateName(String? value) {
    return Validators.required(value, fieldName: 'Nome');
  }

  String? validateEmail(String? value) {
    return Validators.email(value);
  }

  Future<bool> updateProfile(Map<String, dynamic> data, BuildContext context) async {
    // Validações
    if (data['name'] != null) {
      final nameError = validateName(data['name']);
      if (nameError != null) {
        _errorMessage = nameError;
        notifyListeners();
        Helpers.showError(context, nameError);
        return false;
      }
    }

    if (data['email'] != null) {
      final emailError = validateEmail(data['email']);
      if (emailError != null) {
        _errorMessage = emailError;
        notifyListeners();
        Helpers.showError(context, emailError);
        return false;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.updateMyProfile(data);
      await loadProfile(); // Recarregar perfil atualizado
      _isEditing = false;
      _isLoading = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Perfil atualizado com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _authService.logout();
      Helpers.showSuccess(context, 'Logout realizado com sucesso!');
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: ${e.toString()}';
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
    }
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
