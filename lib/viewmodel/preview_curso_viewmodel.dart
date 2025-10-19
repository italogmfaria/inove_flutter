import 'package:flutter/material.dart';
import '../model/course_model.dart';
import '../model/feedback_model.dart';
import '../services/course_service.dart';
import '../services/feedback_service.dart';
import '../core/utils/helpers.dart';

class PreviewCursoViewModel extends ChangeNotifier {
  final CursoService _cursoService;
  final FeedbackService _feedbackService;

  CursoModel? _curso;
  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEnrolling = false;

  PreviewCursoViewModel(this._cursoService, this._feedbackService);

  CursoModel? get curso => _curso;
  List<FeedbackModel> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEnrolling => _isEnrolling;

  void setCurso(CursoModel curso) {
    _curso = curso;
    notifyListeners();
  }

  Future<void> loadCurso(int cursoId, {BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _curso = await _cursoService.getCursoById(cursoId);
      await loadFeedbacks(cursoId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar curso: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (context != null) {
        Helpers.showError(context, _errorMessage!);
      }
    }
  }

  Future<void> loadFeedbacks(int cursoId) async {
    try {
      _feedbacks = await _feedbackService.getFeedbacksByCourse(cursoId);
      notifyListeners();
    } catch (e) {
      // Falha ao carregar feedbacks não impede a visualização do curso
      print('Erro ao carregar feedbacks: ${e.toString()}');
    }
  }

  Future<bool> enrollCourse(int cursoId, BuildContext context) async {
    _isEnrolling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cursoService.enrollCourse(cursoId);
      _isEnrolling = false;
      notifyListeners();
      Helpers.showSuccess(context, 'Inscrição realizada com sucesso!');
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao se inscrever no curso: ${e.toString()}';
      _isEnrolling = false;
      notifyListeners();
      Helpers.showError(context, _errorMessage!);
      return false;
    }
  }

  void navigateToCursoPainel(BuildContext context) {
    if (_curso != null) {
      Navigator.of(context).pushReplacementNamed('/painel-curso', arguments: _curso);
    }
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
