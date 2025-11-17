import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/constants.dart';

class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? Constants.baseUrl;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (needsAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {bool needsAuth = true}) async {
    final headers = await _getHeaders(needsAuth: needsAuth);
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro na requisição GET: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {bool needsAuth = false}) async {
    final headers = await _getHeaders(needsAuth: needsAuth);
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

  // POST que aceita string diretamente no body (para feedbacks, etc)
  Future<dynamic> postString(String endpoint, String body,
      {bool needsAuth = false}) async {
    final token = needsAuth ? await getToken() : null;
    final headers = {
      'Content-Type': 'text/plain; charset=utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,  // Envia a string diretamente, sem jsonEncode
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {bool needsAuth = true}) async {
    final headers = await _getHeaders(needsAuth: needsAuth);
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro na requisição PUT: $e');
    }
  }

  // PUT que aceita string diretamente no body (para feedbacks, etc)
  Future<dynamic> putString(String endpoint, String body,
      {bool needsAuth = true}) async {
    final token = needsAuth ? await getToken() : null;
    final headers = {
      'Content-Type': 'text/plain; charset=utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body,  // Envia a string diretamente, sem jsonEncode
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro na requisição PUT: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {bool needsAuth = true}) async {
    final headers = await _getHeaders(needsAuth: needsAuth);
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro na requisição DELETE: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
