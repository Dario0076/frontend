import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_registro_dto.dart';
import '../config/api_config.dart';

class UsuarioService {
  String get baseUrl => ApiConfig.usuariosBaseUrl;

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
      Uri.parse('$baseUrl/first'),
      headers: headers, // Usar los headers obtenidos
      body: jsonEncode(dto.toJson()),
    );
  }

  Future<bool> login(String correo, String contrasena) async {
    try {
      final loginUrl = '$baseUrl/login';
      print('=== DEBUG LOGIN ===');
      print('URL de login: $loginUrl');
      print('Correo: $correo');
      print('===================');

      final response = await http
          .post(
            Uri.parse(loginUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
          )
          .timeout(
            ApiConfig.timeout,
          ); // Usar timeout de ApiConfig (30 segundos)

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar token JWT
        if (data['token'] != null) {
          await saveToken(data['token']);
          print('Token guardado exitosamente');
        }

        // Guardar información del usuario
        if (data['usuario'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('usuario_data', jsonEncode(data['usuario']));
          print('Datos de usuario guardados exitosamente');
        }

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

  Future<Map<String, dynamic>> getUsuarioLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('usuario_data');
    if (userData != null) {
      final data = jsonDecode(userData);
      return {
        'id': data['id'],
        'nombre': data['nombre'],
        'correo': data['correo'],
        'rol': data['rol'],
      };
    }
    return {'id': null, 'nombre': null, 'correo': null, 'rol': null};
  }

  Future<int?> getUsuarioId() async {
    final usuario = await getUsuarioLogueado();
    return usuario['id'];
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
