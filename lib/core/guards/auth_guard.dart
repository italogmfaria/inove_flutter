import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

/// Tipos de proteção de rota
enum RouteGuardType {
  onlyGuest,     // Apenas para não logados (login, cadastro, etc)
  onlyAuth,      // Apenas para logados (perfil, meus cursos, etc)
  public,        // Público (cursos, preview)
}

class AuthGuard {
  static final AuthService _authService = AuthService(ApiService());

  /// Verifica se o usuário pode acessar a rota
  static Future<bool> canActivate(RouteGuardType guardType) async {
    final isLoggedIn = await _authService.isLoggedIn();

    switch (guardType) {
      case RouteGuardType.onlyGuest:
        // Só pode acessar se NÃO estiver logado
        return !isLoggedIn;

      case RouteGuardType.onlyAuth:
        // Só pode acessar se ESTIVER logado
        return isLoggedIn;

      case RouteGuardType.public:
        // Sempre pode acessar
        return true;
    }
  }

  /// Redireciona baseado no tipo de guarda e estado de autenticação
  static Future<String?> getRedirectRoute(RouteGuardType guardType) async {
    final isLoggedIn = await _authService.isLoggedIn();

    switch (guardType) {
      case RouteGuardType.onlyGuest:
        // Se estiver logado e tentar acessar rota de guest, vai para cursos
        return isLoggedIn ? AppRoutes.cursos : null;

      case RouteGuardType.onlyAuth:
        // Se não estiver logado e tentar acessar rota protegida, vai para login
        return !isLoggedIn ? AppRoutes.login : null;

      case RouteGuardType.public:
        // Nunca redireciona
        return null;
    }
  }

  /// Wrapper para proteger uma rota
  static Widget guardRoute({
    required RouteGuardType guardType,
    required Widget child,
    required BuildContext context,
  }) {
    return FutureBuilder<String?>(
      future: getRedirectRoute(guardType),
      builder: (context, snapshot) {
        // Enquanto verifica autenticação, mostra loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Se precisa redirecionar
        final redirectRoute = snapshot.data;
        if (redirectRoute != null) {
          // Redireciona após o frame atual
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(redirectRoute);
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Pode acessar a rota
        return child;
      },
    );
  }
}

