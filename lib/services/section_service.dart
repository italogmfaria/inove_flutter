import '../model/section_model.dart';
import 'api_service.dart';

class SectionService {
  final ApiService _apiService;

  SectionService(this._apiService);

  // Listar seções de um curso
  Future<List<SectionModel>> getSections(int courseId) async {
    final response = await _apiService.get('/cursos/$courseId/secoes');
    return (response as List)
        .map((section) => SectionModel.fromJson(section))
        .toList();
  }

  // Buscar seção específica
  Future<SectionModel> getSectionById(int courseId, int sectionId) async {
    final response = await _apiService.get('/cursos/$courseId/secoes/$sectionId');
    return SectionModel.fromJson(response);
  }
}

