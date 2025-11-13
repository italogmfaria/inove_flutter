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

  // TODO: Quando o backend estiver pronto, substitua este valor pelo progresso real do usuário
  double getCourseProgress(CursoModel curso) {
    // Valor padrão temporário: varia entre 20% e 75%
    // Futuramente, este valor virá do backend
    final progressMap = {
      0: 0.75, // 75%
      1: 0.40, // 40%
      2: 0.20, // 20%
    };

    // Usa o ID do curso ou índice para variar o progresso
    final index = curso.id != null ? curso.id! % 3 : 0;
    return progressMap[index] ?? 0.30;
  }

  void navigateToCursoPainel(BuildContext context, CursoModel curso) {
    Navigator.of(context).pushNamed('/painel-curso', arguments: curso);
  }

  void navigateToAllCursos(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/cursos');
  }
}

