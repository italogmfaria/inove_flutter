import 'package:flutter/material.dart';

class InicialViewModel extends ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }

  void navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed('/cadastro');
  }
}
