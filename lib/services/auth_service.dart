import 'package:shared_preferences/shared_preferences.dart';
import '../model/auth_response.dart';
import '../model/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiService.post(
      '/auth/login',
      {'email': email, 'password': password},
      needsAuth: false,
    );

    final authResponse = AuthResponse.fromJson(response);
    await _apiService.setToken(authResponse.token);

    // Buscar perfil do usuário para verificar role
    try {
      final userResponse = await _apiService.get('/usuarios/${authResponse.userId}');
      final user = UserModel.fromJson(userResponse);

      // Se não for STUDENT, rejeitar login silenciosamente
      if (!user.isStudent()) {
        // Limpar tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('authToken');
        await prefs.remove('refreshToken');
        await prefs.remove('userId');
        // Lançar erro genérico que será interpretado como credenciais inválidas
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      // Se deu erro ao buscar perfil ou não é student, limpar e rejeitar
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('refreshToken');
      await prefs.remove('userId');
      throw Exception('Invalid credentials');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', authResponse.refreshToken);
    await prefs.setInt('userId', authResponse.userId);

    return authResponse;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
