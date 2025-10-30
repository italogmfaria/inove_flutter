import 'package:shared_preferences/shared_preferences.dart';
import '../model/feedback_model.dart';
import 'api_service.dart';

class FeedbackService {
  final ApiService _apiService;

  FeedbackService(this._apiService);

  // Listar feedbacks de um curso
  Future<List<FeedbackModel>> getFeedbacksByCourse(int courseId) async {
    final response = await _apiService.get('/feedbacks/course/$courseId');
    return (response as List)
        .map((feedback) => FeedbackModel.fromJson(feedback))
        .toList();
  }

  // Adicionar feedback ao curso
  Future<FeedbackModel> addFeedback(int courseId, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    // Usa postString para enviar apenas a string do comentário
    final response = await _apiService.postString(
      '/feedbacks?userId=$userId&courseId=$courseId',
      comment,  // Envia apenas a string, não um objeto
    );

    return FeedbackModel.fromJson(response);
  }

  // Atualizar feedback próprio
  Future<FeedbackModel> updateMyFeedback(int feedbackId, String newComment) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    final response = await _apiService.put(
      '/feedbacks/$feedbackId?userId=$userId',
      {'comment': newComment},
    );
    return FeedbackModel.fromJson(response);
  }

  // Deletar feedback próprio
  Future<void> deleteMyFeedback(int feedbackId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    await _apiService.delete('/feedbacks/$feedbackId?userId=$userId');
  }
}

