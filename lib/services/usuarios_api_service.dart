import 'dart:convert';
import 'package:http/http.dart' as http;

class Usuario {
  final int? id;
  final String correo;
  final String nombreUsuario;
  final String contrasena;
  final String rol;
  final bool activo;

  Usuario({
    this.id,
    required this.correo,
    required this.nombreUsuario,
    required this.contrasena,
    required this.rol,
    this.activo = true,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      correo: json['correo'] ?? '',
      nombreUsuario: json['nombre'] ?? '', // Corregido: el backend usa 'nombre'
      contrasena: json['contrasena'] ?? '',
      rol: json['rol'] ?? '',
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': correo,
      'nombre': nombreUsuario, // Corregido: enviar como 'nombre' al backend
      'contrasena': contrasena,
      'rol': rol,
      'activo': activo,
    };
  }
}

class UsuariosApiService {
  static const String baseUrl = 'http://localhost:8083/usuarios';

  static Future<List<Usuario>> getUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getUsuarios: $e');
      return [];
    }
  }

  static Future<Usuario?> createUsuario(
    Usuario usuario,
    String adminEmail,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Email': adminEmail,
        },
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Usuario.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createUsuario: $e');
      return null;
    }
  }

  static Future<bool> deleteUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error en deleteUsuario: $e');
      return false;
    }
  }

  static Future<Usuario?> updateUsuario(Usuario usuario) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${usuario.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 200) {
        return Usuario.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateUsuario: $e');
      return null;
    }
  }
}
