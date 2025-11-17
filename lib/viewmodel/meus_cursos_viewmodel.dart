import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/course_model.dart';
import '../services/user_service.dart';
import '../services/user_progress_service.dart';
import '../core/utils/helpers.dart';

class MeusCursosViewModel extends ChangeNotifier {
  final UserService _userService;
  final UserProgressService _userProgressService;

  List<CursoModel> _meusCursos = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<int, double> _courseProgressMap = {}; // courseId -> progress percentage

  MeusCursosViewModel(this._userService, this._userProgressService);

  List<CursoModel> get meusCursos => _meusCursos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMeusCursos({BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meusCursos = await _userService.getMyCourses();

      // Carregar progresso para cada curso
      await _loadProgressForAllCourses();

      _isLoading = false;
      _errorMessage = null; // Limpa qualquer erro anterior
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao carregar cursos: ${e.toString()}';
      notifyListeners();
      if (context != null) {
        Helpers.showError(context, _errorMessage!);
      }
    }
  }

  // Carregar progresso de todos os cursos
  Future<void> _loadProgressForAllCourses() async {
    final userId = await _getUserId();
    if (userId == null) {
      debugPrint('[MeusCursosViewModel] UserId não encontrado');
      return;
    }

    for (var curso in _meusCursos) {
      if (curso.id != null) {
        try {
          final progressData = await _userProgressService.getUserProgress(curso.id!, userId);
          final completePercentage = progressData['completePercentage'] as double?;
          _courseProgressMap[curso.id!] = completePercentage ?? 0.0;
        } catch (e) {
          debugPrint('[MeusCursosViewModel] Erro ao carregar progresso do curso ${curso.id}: $e');
          _courseProgressMap[curso.id!] = 0.0;
        }
      }
    }
  }

  // Obter userId do storage
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Obter progresso real do curso
  double getCourseProgress(CursoModel curso) {
    if (curso.id == null) return 0.0;
    return _courseProgressMap[curso.id] ?? 0.0;
  }

  void navigateToCursoPainel(BuildContext context, CursoModel curso) {
    Navigator.of(context).pushNamed('/painel-curso', arguments: curso);
  }

  void navigateToAllCursos(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/cursos');
  }
}

