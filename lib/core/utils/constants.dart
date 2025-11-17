class Constants {
  // Environment Configuration
  static const bool isProduction = true;

  // API Configuration
  static const String devBaseUrl = 'http://localhost:8080/api/inove';
  static const String prodBaseUrl = 'https://inove-production.up.railway.app/api/inove';

  // URL ativa baseada no ambiente
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // Storage Keys
  static const String authTokenKey = 'authToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userIdKey = 'userId';

  // App Configuration
  static const String appName = 'Inove';
  static const int timeoutDuration = 30;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int codeLength = 6;

  // Pagination
  static const int itemsPerPage = 10;
}
