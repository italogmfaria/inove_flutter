import 'package:shared_preferences/shared_preferences.dart';
import '../model/school_model.dart';
import 'api_service.dart';

class SchoolService {
  final ApiService _apiService;

  SchoolService(this._apiService);

  // Buscar a escola do estudante logado
  Future<SchoolModel> getMySchool() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    // Primeiro busca o perfil do usuário para pegar o schoolId
    final userResponse = await _apiService.get('/usuarios/$userId');
    final schoolId = userResponse['schoolId'];

    if (schoolId == null) {
      throw Exception('Estudante não está vinculado a nenhuma escola.');
    }

    // Busca os dados da escola
    final response = await _apiService.get('/escolas/$schoolId');
    return SchoolModel.fromJson(response);
  }

  // Listar todas as escolas (para seleção no cadastro)
  Future<List<SchoolModel>> getSchools() async {
    final response = await _apiService.get('/escolas', needsAuth: false);
    return (response as List)
        .map((school) => SchoolModel.fromJson(school))
        .toList();
  }

  // Adicionar nova escola
  Future<void> addSchool(SchoolModel school) async {
    await _apiService.post('/escolas', school.toJson());
  }
}

