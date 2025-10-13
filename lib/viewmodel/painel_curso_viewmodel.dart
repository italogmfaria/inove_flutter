import 'package:flutter/material.dart';
import '../model/curso_model.dart';

class PainelCursoViewModel extends ChangeNotifier {
  CursoModel? _curso;
  int _currentAulaIndex = 0;
  double _progress = 0.0;
  bool _isLoading = false;

  CursoModel? get curso => _curso;
  int get currentAulaIndex => _currentAulaIndex;
  double get progress => _progress;
  bool get isLoading => _isLoading;

  void setCurso(CursoModel curso) {
    // TODO: Implementar lógica
  }

  void setCurrentAula(int index) {
    // TODO: Implementar lógica
  }

  void nextAula() {
    // TODO: Implementar lógica
  }

  void previousAula() {
    // TODO: Implementar lógica
  }

  Future<void> markAulaAsCompleted(int aulaId) async {
    // TODO: Implementar lógica de marcar aula como concluída
  }

  void navigateBack(BuildContext context) {
    // TODO: Implementar navegação
  }
}
