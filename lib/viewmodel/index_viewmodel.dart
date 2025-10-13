import 'package:flutter/material.dart';

class IndexViewModel extends ChangeNotifier {
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> initialize(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));

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
    // TODO: Implementar verificação de autenticação real
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }
}