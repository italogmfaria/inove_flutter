import 'package:flutter/material.dart';
import '../model/curso_model.dart';

class PreviewCursoViewModel extends ChangeNotifier {
  CursoModel? _curso;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEnrolling = false;

  CursoModel? get curso => _curso;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEnrolling => _isEnrolling;

  void setCurso(CursoModel curso) {
    // TODO: Implementar lógica
  }

  Future<void> loadCurso(int cursoId) async {
    // TODO: Implementar lógica de carregamento do curso
  }

  Future<bool> enrollCourse(int userId, int cursoId) async {
    // TODO: Implementar lógica de inscrição no curso
    return false;
  }

  void navigateToCursoPainel(BuildContext context) {
    // TODO: Implementar navegação
  }

  void navigateBack(BuildContext context) {
    // TODO: Implementar navegação
  }
}
