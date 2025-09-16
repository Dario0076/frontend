import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_registro_dto.dart';
import '../config/api_config.dart';

/// Servicio para gestionar usuarios y autenticación JWT en el frontend.
/// Aquí se maneja el almacenamiento, recuperación y borrado del token JWT,
/// así como el login y la obtención de datos del usuario logueado.
class UsuarioService {
  /// Devuelve la URL base del microservicio de usuarios.
  String get baseUrl => ApiConfig.usuariosBaseUrl;

  /// Obtiene el token JWT almacenado localmente en SharedPreferences.
  /// Usado para autenticar peticiones a la API.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Guarda el token JWT después de un login exitoso.
  /// Llama a este método tras recibir el token del backend.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  /// Elimina el token JWT del almacenamiento local (logout).
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  /// Devuelve los headers necesarios para peticiones autenticadas.
  /// Incluye el JWT si está disponible.
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Registra el primer usuario (admin) en el sistema.
  /// Utiliza el endpoint /first del microservicio de usuarios.
  Future<http.Response> registrarUsuario(UsuarioRegistroDTO dto) async {
    final headers = await getAuthHeaders();
    return http.post(
      Uri.parse('$baseUrl/first'),
      headers: headers, // Usar los headers obtenidos
      body: jsonEncode(dto.toJson()),
    );
  }

  /// Realiza el login del usuario.
  /// Si es exitoso, guarda el JWT y los datos del usuario en SharedPreferences.
  /// Devuelve true si el login fue exitoso, false en caso contrario.
  Future<bool> login(String correo, String contrasena) async {
    try {
      final loginUrl = '$baseUrl/login';
      final response = await http
          .post(
            Uri.parse(loginUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
          )
          .timeout(ApiConfig.timeout); // Usar timeout de ApiConfig

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar token JWT recibido del backend
        if (data['token'] != null) {
          await saveToken(data['token']);
        }

        // Guardar información del usuario logueado
        if (data['usuario'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('usuario_data', jsonEncode(data['usuario']));
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Obtiene los datos del usuario actualmente logueado desde SharedPreferences.
  /// Devuelve un mapa con id, nombre, correo y rol.
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

  /// Devuelve el ID del usuario actualmente logueado.
  Future<int?> getUsuarioId() async {
    final usuario = await getUsuarioLogueado();
    return usuario['id'];
  }

  /// Indica si hay un usuario logueado (si existe un JWT almacenado).
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Elimina el JWT y los datos del usuario (logout).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('usuario_data');
  }

  /// Crea el primer usuario admin (sin autenticación, solo para inicialización).
  Future<http.Response> crearAdminInicial(UsuarioRegistroDTO dto) {
    return http.post(
      Uri.parse('$baseUrl/init-admin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
  }
}
