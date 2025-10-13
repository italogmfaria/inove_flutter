import 'package:flutter/material.dart';
import '../model/curso_model.dart';

class CursosViewModel extends ChangeNotifier {
  List<CursoModel> _cursos = [];
  List<CursoModel> _filteredCursos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<CursoModel> get cursos => _filteredCursos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> loadCursos() async {
    // TODO: Implementar lógica de carregamento de cursos
  }

  void searchCursos(String query) {
    // TODO: Implementar lógica de busca
  }

  void navigateToCursoPreview(BuildContext context, CursoModel curso) {
    // TODO: Implementar navegação
  }

  void navigateToMeusCursos(BuildContext context) {
    // TODO: Implementar navegação
  }

  void navigateToPerfil(BuildContext context) {
    // TODO: Implementar navegação
  }
}
