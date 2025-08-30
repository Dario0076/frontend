import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_registro_dto.dart';

class UsuarioService {
  final String baseUrl = 'http://localhost:8083/usuarios';

  Future<http.Response> registrarUsuario(UsuarioRegistroDTO dto) {
    return http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
  }

  Future<bool> login(String correo, String contrasena) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return true;
      }
    }
    return false;
  }
}