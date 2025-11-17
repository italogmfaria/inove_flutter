import 'package:shared_preferences/shared_preferences.dart';
import '../model/completed_content_model.dart';
import 'api_service.dart';

class UserProgressService {
  final ApiService _apiService;

  UserProgressService(this._apiService);

  // Marcar conteúdo como concluído
  Future<CompletedContent> markContentAsCompleted(
    int courseId,
    int sectionId,
    int contentId,
    int userId,
  ) async {
    final response = await _apiService.post(
      '/cursos/$courseId/secoes/$sectionId/conteudos/$contentId/discente/$userId/progresso',
      {},
      needsAuth: true,
    );
    return CompletedContent.fromJson(response);
  }

  // Buscar progresso do usuário em um curso
  Future<Map<String, dynamic>> getUserProgress(int courseId, int userId) async {
    final response = await _apiService.get(
      '/cursos/$courseId/discente/$userId/progresso',
      needsAuth: true,
    );
    return response as Map<String, dynamic>;
  }

  // Buscar progresso do usuário atual em um curso
  Future<Map<String, dynamic>> getCurrentUserProgress(int courseId) async {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      throw Exception('Usuário não está logado');
    }
    return getUserProgress(courseId, userId);
  }

  // Marcar conteúdo como concluído para o usuário atual
  Future<CompletedContent> markContentAsCompletedForCurrentUser(
    int courseId,
    int sectionId,
    int contentId,
  ) async {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      throw Exception('Usuário não está logado');
    }
    return markContentAsCompleted(courseId, sectionId, contentId, userId);
  }

  // Verificar se um conteúdo foi concluído
  Future<bool> isContentCompleted(int courseId, int contentId) async {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      return false;
    }

    try {
      final progress = await getUserProgress(courseId, userId);
      final completedContents = progress['completedContents'] as List?;
      if (completedContents == null) return false;

      return completedContents.any((c) => c['contentId'] == contentId);
    } catch (e) {
      print('[UserProgressService] Erro ao verificar conteúdo concluído: $e');
      return false;
    }
  }

  // Obter porcentagem de progresso como número
  int getPercentageAsNumber(Map<String, dynamic> progress) {
    final percentage = progress['completePercentage'] as double? ?? 0.0;
    return (percentage * 100).round();
  }

  // Obter porcentagem formatada como string
  String getFormattedPercentage(Map<String, dynamic> progress) {
    return '${getPercentageAsNumber(progress)}%';
  }

  // Obter ID do usuário atual do SharedPreferences
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}

