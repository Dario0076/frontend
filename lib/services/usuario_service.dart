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
    try {
      print('Intentando login con correo: $correo');
      final response = await http.post(
        Uri.parse('http://localhost:8083/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Datos del usuario: $data');
        // Guardar información del usuario logueado
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('usuario_nombre', data['nombre'] ?? 'Usuario');
        await prefs.setString('usuario_correo', data['correo'] ?? '');
        await prefs.setString('usuario_rol', data['rol'] ?? 'USER');
        print('Login exitoso');
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
    return {
      'nombre': prefs.getString('usuario_nombre'),
      'correo': prefs.getString('usuario_correo'),
      'rol': prefs.getString('usuario_rol'),
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_nombre');
    await prefs.remove('usuario_correo');
    await prefs.remove('usuario_rol');
  }
}
