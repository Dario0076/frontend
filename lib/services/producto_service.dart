import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_registro_dto.dart';
import '../config/api_config.dart';

class ProductoService {
  String get baseUrl => ApiConfig.productosBaseUrl;

  Future<http.Response> registrarProducto(ProductoRegistroDTO dto) async {
    try {
      return await http
          .post(
            Uri.parse(baseUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(dto.toJson()),
          )
          .timeout(ApiConfig.timeout);
    } catch (e) {
      rethrow;
    }
  }
}
