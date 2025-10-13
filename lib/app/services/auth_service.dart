import '../utils/constants.dart';
import '../../model/auth_response.dart';
import '../../model/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<AuthResponse> login(String email, String password) async {
    // TODO: Implementar lógica de login
    throw UnimplementedError();
  }

  Future<AuthResponse> register(UserModel user, String password) async {
    // TODO: Implementar lógica de registro
    throw UnimplementedError();
  }

  Future<void> forgotPassword(String email) async {
    // TODO: Implementar lógica de esqueci senha
    throw UnimplementedError();
  }

  Future<bool> verifyCode(String email, String code) async {
    // TODO: Implementar lógica de verificação de código
    throw UnimplementedError();
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    // TODO: Implementar lógica de redefinir senha
    throw UnimplementedError();
  }

  Future<void> logout() async {
    // TODO: Implementar lógica de logout
  }
}
