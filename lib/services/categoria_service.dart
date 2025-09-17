import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class Categoria {
  final int? id;
  final String nombre;
  final String descripcion;

  Categoria({this.id, required this.nombre, required this.descripcion});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'descripcion': descripcion};
  }
}

class CategoriaService {
  String get baseUrl => ApiConfig.categoriasBaseUrl;

  Future<List<Categoria>> listarCategorias() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Categoria.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  Future<Categoria?> crearCategoria(Categoria categoria) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(categoria.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Categoria.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear categoría: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> eliminarCategoria(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: ApiConfig.defaultHeaders,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<Categoria?> editarCategoria(Categoria categoria) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${categoria.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(categoria.toJson()),
      );
      if (response.statusCode == 200) {
        return Categoria.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al editar categoría: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }
}
