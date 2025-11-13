import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../model/course_model.dart';
import '../model/school_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  // Registro de novo estudante
  Future<void> registerStudent(Map<String, dynamic> studentData) async {
    await _apiService.post('/usuarios/discente', studentData, needsAuth: false);
  }

  // Obter perfil do estudante logado
  Future<UserModel> getMyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    final response = await _apiService.get('/usuarios/$userId');
    return UserModel.fromJson(response);
  }

  // Atualizar perfil do estudante logado
  Future<void> updateMyProfile(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    await _apiService.put('/usuarios/$userId', userData);
  }

  // Obter cursos do estudante logado
  Future<List<CursoModel>> getMyCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    try {
      final response = await _apiService.get('/usuarios/$userId/cursos');

      List<dynamic> coursesList = [];

      if (response is List) {
        coursesList = response;
      } else if (response is Map) {
        if (response['courses'] != null) {
          coursesList = response['courses'];
        } else if (response['cursos'] != null) {
          coursesList = response['cursos'];
        } else if (response['data'] != null) {
          coursesList = response['data'];
        } else {
          final keys = response.keys.toList();
          if (keys.length == 1 && response[keys[0]] is List) {
            coursesList = response[keys[0]];
          }
        }
      }

      return coursesList
          .map((curso) => CursoModel.fromJson(curso))
          .toList();
    } catch (e) {
      // Se o erro for 404 ou indicar que não há cursos, retorna lista vazia
      if (e.toString().contains('404') ||
          e.toString().toLowerCase().contains('não encontrado') ||
          e.toString().toLowerCase().contains('not found')) {
        return [];
      }
      // Caso contrário, repassa o erro
      rethrow;
    }
  }

  // Desinscrever-se de um curso
  Future<void> unenrollFromCourse(int courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    await _apiService.delete('/usuarios/$userId/cursos/$courseId');
  }

  // Obter escola do estudante logado
  Future<SchoolModel?> getMySchool() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    try {
      final response = await _apiService.get('/usuarios/$userId/school');
      if (response != null && response is Map<String, dynamic>) {
        return SchoolModel.fromJson(response);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
