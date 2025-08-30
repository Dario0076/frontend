import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria_registro_dto.dart';

class CategoriaService {
  final String baseUrl = 'http://localhost:8080/categorias';

  Future<http.Response> registrarCategoria(CategoriaRegistroDTO dto) {
    return http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
  }
  Future<List<Map<String, dynamic>>> listarCategorias() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar categorías');
    }
  }
}