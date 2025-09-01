import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_registro_dto.dart';

class ProductoService {
  final String baseUrl = 'http://localhost:8084/productos';

  Future<http.Response> registrarProducto(ProductoRegistroDTO dto) {
    return http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
  }
}
