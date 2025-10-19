import 'package:flutter/material.dart';
import '../model/course_model.dart';
import '../services/course_service.dart';
import '../core/utils/helpers.dart';

class CursosViewModel extends ChangeNotifier {
  final CursoService _cursoService;

  List<CursoModel> _cursos = [];
  List<CursoModel> _filteredCursos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  CursosViewModel(this._cursoService);

  List<CursoModel> get cursos => _filteredCursos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> loadCursos({BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cursos = await _cursoService.getCursos();
      _filteredCursos = _cursos;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar cursos: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (context != null) {
        Helpers.showError(context, _errorMessage!);
      }
    }
  }

  void searchCursos(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredCursos = _cursos;
    } else {
      _filteredCursos = _cursos.where((curso) {
        return curso.name.toLowerCase().contains(query.toLowerCase()) ||
            curso.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void navigateToCursoPreview(BuildContext context, CursoModel curso) {
    Navigator.of(context).pushNamed('/preview-curso', arguments: curso);
  }

  void navigateToMeusCursos(BuildContext context) {
    Navigator.of(context).pushNamed('/meus-cursos');
  }

  void navigateToPerfil(BuildContext context) {
    Navigator.of(context).pushNamed('/perfil');
  }
}
