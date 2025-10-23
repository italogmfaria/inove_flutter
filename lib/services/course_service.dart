import 'package:shared_preferences/shared_preferences.dart';
import '../model/course_model.dart';
import 'api_service.dart';

class CursoService {
  final ApiService _apiService;

  CursoService(this._apiService);

  // Listar todos os cursos disponíveis
  Future<List<CursoModel>> getCursos() async {
    final response = await _apiService.get('/cursos');
    return (response as List)
        .map((curso) => CursoModel.fromJson(curso))
        .toList();
  }

  // Buscar curso por ID
  Future<CursoModel> getCursoById(int id) async {
    final response = await _apiService.get('/cursos/$id');
    return CursoModel.fromJson(response);
  }

  // Inscrever-se em um curso
  Future<void> enrollCourse(int cursoId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    await _apiService.post(
      '/usuarios/$userId/inscreverse/$cursoId',
      {},
    );
  }

  // Buscar cursos por termo
  Future<List<CursoModel>> searchCursos(String query) async {
    final response = await _apiService.get('/cursos?search=$query');
    return (response as List)
        .map((curso) => CursoModel.fromJson(curso))
        .toList();
  }
}

