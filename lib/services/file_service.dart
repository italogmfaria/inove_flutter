import '../services/api_service.dart';

class FileService {
  final ApiService _apiService;

  FileService(this._apiService);

  // Obter URL da imagem do curso através do backend
  // Retorna a URL da imagem que está no S3
  Future<String?> getCourseImageUrl(int courseId) async {
    try {
      final response = await _apiService.get('/cursos/$courseId/preview-imagem', needsAuth: false);
      if (response != null && response['imageUrl'] != null) {
        return response['imageUrl'] as String;
      }
      return null;
    } catch (e) {
      print('Erro ao obter URL da imagem do curso: $e');
      return null;
    }
  }

  // Obter URL completa para stream de conteúdo
  String getStreamUrl(String fileName) {
    return '${_apiService.baseUrl}/cursos/secoes/conteudos/stream/$fileName';
  }

  // Obter URL completa da imagem do curso
  String getCourseImageFullUrl(String imageUrl) {
    // Se já for uma URL completa, retorna como está
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    // Caso contrário, concatena com a base URL
    return '${_apiService.baseUrl}$imageUrl';
  }
}

