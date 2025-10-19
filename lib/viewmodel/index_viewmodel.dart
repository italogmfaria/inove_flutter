import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class IndexViewModel extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = true;

  IndexViewModel(this._authService);

  bool get isLoading => _isLoading;

  Future<void> initialize(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final isAuthenticated = await checkAuthentication();

    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        isAuthenticated ? '/cursos' : '/inicial',
      );
    }
  }

  Future<bool> checkAuthentication() async {
    try {
      return await _authService.isLoggedIn();
    } catch (e) {
      print('Erro ao verificar autenticação: ${e.toString()}');
      return false;
    }
  }
}