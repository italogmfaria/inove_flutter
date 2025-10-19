import 'package:flutter/material.dart';
import '../model/course_model.dart';
import '../services/user_service.dart';
import '../core/utils/helpers.dart';

class MeusCursosViewModel extends ChangeNotifier {
  final UserService _userService;

  List<CursoModel> _meusCursos = [];
  bool _isLoading = false;
  String? _errorMessage;

  MeusCursosViewModel(this._userService);

  List<CursoModel> get meusCursos => _meusCursos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMeusCursos({BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meusCursos = await _userService.getMyCourses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar seus cursos: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (context != null) {
        Helpers.showError(context, _errorMessage!);
      }
    }
  }

  void navigateToCursoPainel(BuildContext context, CursoModel curso) {
    Navigator.of(context).pushNamed('/painel-curso', arguments: curso);
  }

  void navigateToAllCursos(BuildContext context) {
    Navigator.of(context).pushNamed('/cursos');
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
