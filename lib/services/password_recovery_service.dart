import 'api_service.dart';

class PasswordRecoveryService {
  final ApiService _apiService;

  PasswordRecoveryService(this._apiService);

  Future<void> requestRecoveryCode(String email) async {
    await _apiService.post(
      '/auth/forgot-password/$email',
      {},
      needsAuth: false,
    );
  }

  Future<void> verifyRecoveryCode(String email, String code) async {
    await _apiService.post(
      '/auth/verify-code',
      {'email': email, 'code': code},
      needsAuth: false,
    );
  }

  Future<void> resetPassword(String email, String code, String password) async {
    await _apiService.post(
      '/auth/reset-password',
      {'email': email, 'code': code, 'password': password},
      needsAuth: false,
    );
  }
}

