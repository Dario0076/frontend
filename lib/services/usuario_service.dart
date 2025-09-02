import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_registro_dto.dart';

class UsuarioService {
  final String baseUrl = 'http://localhost:8083/api/usuarios';

  // Obtener token JWT almacenado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Guardar token JWT
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Eliminar token JWT
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Obtener headers con autorización
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> registrarUsuario(UsuarioRegistroDTO dto) async {
    final headers = await getAuthHeaders();
    return http.post(
      Uri.parse('$baseUrl/first'), // Usar endpoint para primer usuario
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
  }

  Future<bool> login(String correo, String contrasena) async {
    try {
      print('Iniciando sesión con correo: $correo');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar token JWT
        if (data['token'] != null) {
          await saveToken(data['token']);
        }

        // Guardar información del usuario
        if (data['usuario'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('usuario_data', jsonEncode(data['usuario']));
        }

        print('Login exitoso - Token recibido');
        return true;
      } else {
        print('Login fallido - Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  Future<Map<String, String?>> getUsuarioLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('usuario_data');
    if (userData != null) {
      final data = jsonDecode(userData);
      return {
        'nombre': data['nombre'],
        'correo': data['correo'],
        'rol': data['rol'],
      };
    }
    return {'nombre': null, 'correo': null, 'rol': null};
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('usuario_data');
  }

  // Crear usuario admin inicial (sin autenticación)
  Future<http.Response> crearAdminInicial(UsuarioRegistroDTO dto) {
    return http.post(
      Uri.parse('$baseUrl/init-admin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
  }
}
