import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movimiento_registro_dto.dart';
import '../config/api_config.dart';

class MovimientoService {
  String get baseUrl => ApiConfig.movimientosBaseUrl;

  Future<http.Response> registrarMovimiento(MovimientoRegistroDTO dto) async {
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
