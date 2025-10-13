import '../utils/constants.dart';
import '../../model/curso_model.dart';
import 'api_service.dart';

class CursoService {
  final ApiService _apiService;

  CursoService(this._apiService);

  Future<List<CursoModel>> getCursos() async {
    // TODO: Implementar lógica de buscar cursos
    throw UnimplementedError();
  }

  Future<CursoModel> getCursoById(int id) async {
    // TODO: Implementar lógica de buscar curso por ID
    throw UnimplementedError();
  }

  Future<List<CursoModel>> getMeusCursos(int userId) async {
    // TODO: Implementar lógica de buscar cursos do usuário
    throw UnimplementedError();
  }

  Future<void> enrollCourse(int userId, int cursoId) async {
    // TODO: Implementar lógica de inscrição no curso
    throw UnimplementedError();
  }

  Future<void> unenrollCourse(int userId, int cursoId) async {
    // TODO: Implementar lógica de cancelar inscrição
    throw UnimplementedError();
  }

  Future<List<CursoModel>> searchCursos(String query) async {
    // TODO: Implementar lógica de busca de cursos
    throw UnimplementedError();
  }
}
