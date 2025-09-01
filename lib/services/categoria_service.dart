import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final String baseUrl = 'http://localhost:8084/categorias';

  Future<List<Categoria>> listarCategorias() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Categoria.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en listarCategorias: $e');
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
      print('Error en crearCategoria: $e');
      return null;
    }
  }
}
