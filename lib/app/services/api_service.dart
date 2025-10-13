import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({this.baseUrl = Constants.baseUrl});

  void setToken(String token) {
    // TODO: Implementar lógica de set token
  }

  Map<String, String> _getHeaders({bool needsAuth = false}) {
    // TODO: Implementar lógica de headers
    return {};
  }

  Future<dynamic> get(String endpoint, {bool needsAuth = true}) async {
    // TODO: Implementar requisição GET
    throw UnimplementedError();
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {bool needsAuth = false}) async {
    // TODO: Implementar requisição POST
    throw UnimplementedError();
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {bool needsAuth = true}) async {
    // TODO: Implementar requisição PUT
    throw UnimplementedError();
  }

  Future<dynamic> delete(String endpoint, {bool needsAuth = true}) async {
    // TODO: Implementar requisição DELETE
    throw UnimplementedError();
  }

  dynamic _handleResponse(http.Response response) {
    // TODO: Implementar tratamento de resposta
    return null;
  }
}
