class Constants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String cursosEndpoint = '/cursos';
  static const String escolasEndpoint = '/escolas';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // App Configuration
  static const String appName = 'Inove';
  static const int timeoutDuration = 30; // seconds

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int codeLength = 6;
}

