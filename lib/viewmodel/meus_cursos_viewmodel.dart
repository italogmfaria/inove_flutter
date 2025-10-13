import 'package:flutter/material.dart';
import '../model/curso_model.dart';

class MeusCursosViewModel extends ChangeNotifier {
  List<CursoModel> _meusCursos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CursoModel> get meusCursos => _meusCursos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMeusCursos(int userId) async {
    // TODO: Implementar lógica de carregamento dos cursos do usuário
  }

  void navigateToCursoPainel(BuildContext context, CursoModel curso) {
    // TODO: Implementar navegação
  }

  void navigateToAllCursos(BuildContext context) {
    // TODO: Implementar navegação
  }

  void navigateBack(BuildContext context) {
    // TODO: Implementar navegação
  }
}
