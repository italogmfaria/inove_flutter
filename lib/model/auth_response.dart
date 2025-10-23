class AuthResponse {
  final String token;
  final String refreshToken;
  final int userId;
  final String? role;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.userId,
    this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      userId: json['userId'] ?? 0,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
      'role': role,
    };
  }

  bool isStudent() {
    if (role == null) return true;

    final upperRole = role!.toUpperCase();
    return upperRole == 'STUDENT' || upperRole == 'DISCENTE';
  }
}
