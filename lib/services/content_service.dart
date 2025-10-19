import '../model/content_model.dart';
import 'api_service.dart';

class ContentService {
  final ApiService _apiService;

  ContentService(this._apiService);

  // Listar conteúdos de uma seção
  Future<List<ContentModel>> getContents(int courseId, int sectionId) async {
    final response = await _apiService.get(
      '/cursos/$courseId/secoes/$sectionId/conteudos',
    );
    return (response as List)
        .map((content) => ContentModel.fromJson(content))
        .toList();
  }

  // Buscar conteúdo específico
  Future<ContentModel> getContentById(
      int courseId, int sectionId, int contentId) async {
    final response = await _apiService.get(
      '/cursos/$courseId/secoes/$sectionId/conteudos/$contentId',
    );
    return ContentModel.fromJson(response);
  }

  // Verificar tipo de arquivo do conteúdo
  Future<Map<String, dynamic>> getFileType(String fileName) async {
    final response = await _apiService.get(
      '/cursos/secoes/conteudos/type/$fileName',
    );
    return response;
  }
}

