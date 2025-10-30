import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../services/user_service.dart';
import '../model/course_model.dart';

class PreviewCursoViewModel extends ChangeNotifier {
  final CursoService _cursoService;
  final UserService _userService;

  bool _isLoading = false;
  bool _isEnrolling = false;
  String? _errorMessage;
  CursoModel? _curso;
  bool _isEnrolled = false;
  Set<int> _expandedSections = {};

  PreviewCursoViewModel(this._cursoService, this._userService);

  bool get isLoading => _isLoading;
  bool get isEnrolling => _isEnrolling;
  String? get errorMessage => _errorMessage;
  CursoModel? get curso => _curso;
  bool get isEnrolled => _isEnrolled;
  Set<int> get expandedSections => _expandedSections;

  Future<void> loadCurso(int cursoId, {BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _curso = await _cursoService.getCursoById(cursoId);
      await checkEnrollmentStatus(cursoId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao carregar curso: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> checkEnrollmentStatus(int cursoId) async {
    try {
      final meusCursos = await _userService.getMyCourses();
      _isEnrolled = meusCursos.any((curso) => curso.id == cursoId);
      notifyListeners();
    } catch (e) {
      print('Erro ao verificar matrícula: $e');
      _isEnrolled = false;
    }
  }

  Future<void> enrollInCourse(BuildContext context) async {
    if (_curso?.id == null) return;

    _isEnrolling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cursoService.enrollCourse(_curso!.id!);
      _isEnrolled = true;
      _isEnrolling = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Matrícula realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _isEnrolling = false;
      final errorMsg = _getErrorMessage(e);
      _errorMessage = errorMsg;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void toggleSection(int sectionIndex) {
    if (_expandedSections.contains(sectionIndex)) {
      _expandedSections.remove(sectionIndex);
    } else {
      _expandedSections.add(sectionIndex);
    }
    notifyListeners();
  }

  bool isSectionExpanded(int sectionIndex) {
    return _expandedSections.contains(sectionIndex);
  }

  void navigateToMeusCursos(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/meus-cursos');
  }

  void navigateToCursoPainel(BuildContext context) {
    if (_curso != null) {
      Navigator.of(context).pushReplacementNamed('/painel-curso', arguments: _curso);
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('already enrolled') ||
        errorMessage.contains('já matriculado')) {
      return 'Você já está matriculado neste curso';
    }

    if (errorMessage.contains('unauthorized') ||
        errorMessage.contains('401')) {
      return 'Você precisa estar logado para se matricular';
    }

    if (errorMessage.contains('timeout') ||
        errorMessage.contains('connection failed')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente';
    }

    return 'Erro ao realizar matrícula. Tente novamente';
  }
}

