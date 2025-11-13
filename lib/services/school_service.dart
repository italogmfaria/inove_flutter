import '../model/school_model.dart';
import 'api_service.dart';

class SchoolService {
  final ApiService _apiService;

  SchoolService(this._apiService);


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

