import '../utils/constants.dart';
import '../../model/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<UserModel> getProfile(int userId) async {
    // TODO: Implementar lógica de buscar perfil
    throw UnimplementedError();
  }

  Future<UserModel> updateProfile(int userId, Map<String, dynamic> data) async {
    // TODO: Implementar lógica de atualizar perfil
    throw UnimplementedError();
  }

  Future<void> changePassword(int userId, String oldPassword, String newPassword) async {
    // TODO: Implementar lógica de alterar senha
    throw UnimplementedError();
  }

  Future<void> deleteAccount(int userId) async {
    // TODO: Implementar lógica de deletar conta
    throw UnimplementedError();
  }

  Future<UserModel?> getUserByEmail(String email) async {
    // TODO: Implementar lógica de buscar usuário por email
    return null;
  }
}
