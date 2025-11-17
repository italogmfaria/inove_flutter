import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/school_model.dart';
import '../model/course_model.dart';
import '../services/user_service.dart';
import '../services/school_service.dart';
import '../services/auth_service.dart';
import '../services/user_progress_service.dart';
import '../core/utils/helpers.dart';
import '../core/utils/validators.dart';

class PerfilViewModel extends ChangeNotifier {
  final UserService _userService;
  final SchoolService _schoolService;
  final AuthService _authService;
  final UserProgressService _userProgressService;

  UserModel? _user;
  SchoolModel? _school;
  List<CursoModel> _myCourses = [];
  List<SchoolModel> _schools = [];
  bool _isLoading = false;
  bool _isLoadingCourses = false;
  bool _isLoadingProgress = false;
  String? _errorMessage;
  bool _isEditing = false;

  // Progresso por curso (courseId -> 0.0..1.0)
  final Map<int, double> _courseProgressById = {};
  // Conteúdos concluídos por curso (courseId -> Set<contentId>)
  final Map<int, Set<int>> _completedContentIdsByCourse = {};

  PerfilViewModel(
    this._userService,
    this._schoolService,
    this._authService,
    this._userProgressService,
  );

  UserModel? get user => _user;
  SchoolModel? get school => _school;
  List<CursoModel> get myCourses => _myCourses;
  List<SchoolModel> get schools => _schools;
  bool get isLoading => _isLoading;
  bool get isLoadingCourses => _isLoadingCourses;
  bool get isLoadingProgress => _isLoadingProgress;
  String? get errorMessage => _errorMessage;
  bool get isEditing => _isEditing;

  // Separa cursos em andamento (< 100%)
  List<CursoModel> get coursesInProgress {
    return _myCourses.where((curso) {
      final progress = getCourseProgress(curso);
      return progress < 1.0;
    }).toList();
  }

  // Separa cursos concluídos (100%)
  List<CursoModel> get completedCourses {
    return _myCourses.where((curso) {
      final progress = getCourseProgress(curso);
      return progress >= 1.0;
    }).toList();
  }

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

      // Sempre tentar carregar a escola via UserService (endpoint /usuarios/{id}/school)
      try {
        _school = await _userService.getMySchool();
      } catch (e) {
        _school = null;
      }

      // Carregar lista de escolas para edição
      await loadSchools();

      // Carregar cursos do usuário e progresso
      await loadMyCourses(loadProgressAfter: true);

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

  Future<void> loadSchools() async {
    try {
      _schools = await _schoolService.getSchools();
      notifyListeners();
    } catch (e) {
      _schools = [];
    }
  }

  Future<void> loadMyCourses({bool loadProgressAfter = false}) async {
    _isLoadingCourses = true;
    notifyListeners();

    try {
      _myCourses = await _userService.getMyCourses();

      // Limpar progresso ao recarregar lista
      _courseProgressById.clear();
      _completedContentIdsByCourse.clear();

      _isLoadingCourses = false;
      notifyListeners();

      if (loadProgressAfter) {
        await loadProgressForMyCourses();
      }
    } catch (e) {
      _myCourses = [];
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  Future<void> loadProgressForMyCourses() async {
    if (_myCourses.isEmpty) return;

    _isLoadingProgress = true;
    notifyListeners();

    try {
      for (final curso in _myCourses) {
        final id = curso.id;
        if (id == null) continue;

        try {
          final progress = await _userProgressService.getCurrentUserProgress(id);

          // Porcentagem correta vem do backend como fração (0..1)
          final completePercentage = (progress['completePercentage'] as double?) ?? 0.0;
          // Sanitize/clamp para nunca passar de 1.0
          final clamped = completePercentage.isNaN
              ? 0.0
              : completePercentage.clamp(0.0, 1.0);
          _courseProgressById[id] = clamped;

          // Guardar IDs de conteúdos concluídos (para consistência com painel)
          final completed = (progress['completedContents'] as List?) ?? const [];
          _completedContentIdsByCourse[id] = completed
              .map((c) => (c['contentId'] as num?)?.toInt())
              .whereType<int>()
              .toSet();
        } catch (e) {
          // Se um curso falhar, continua com os demais
          _courseProgressById[id] = 0.0;
          _completedContentIdsByCourse[id] = <int>{};
        }

        // Notificar de tempos em tempos para feedback de carregamento
        notifyListeners();
      }
    } finally {
      _isLoadingProgress = false;
      notifyListeners();
    }
  }

  // Retorna progresso real do usuário para o curso (0.0..1.0)
  double getCourseProgress(CursoModel curso) {
    final id = curso.id;
    if (id == null) return 0.0;
    final value = _courseProgressById[id] ?? 0.0;
    // Garantir limites (defensivo)
    if (value.isNaN) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  // Acesso opcional aos conteúdos concluídos por curso (se for útil na UI futuramente)
  Set<int> getCompletedContentIdsForCourse(int courseId) {
    return _completedContentIdsByCourse[courseId] ?? <int>{};
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

  Future<bool> unenrollFromCourse(int courseId, BuildContext context) async {
    try {
      await _userService.unenrollFromCourse(courseId);
      // Remover progresso armazenado para o curso removido
      _courseProgressById.remove(courseId);
      _completedContentIdsByCourse.remove(courseId);

      await loadMyCourses(loadProgressAfter: true); // Recarregar lista e progresso
      Helpers.showSuccess(context, 'Inscrição removida com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao remover inscrição do curso: ${e.toString()}';
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
