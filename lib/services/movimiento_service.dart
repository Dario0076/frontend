import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movimiento_registro_dto.dart';

class MovimientoService {
  final String baseUrl = 'http://localhost:8090/movimientos';

  Future<http.Response> registrarMovimiento(MovimientoRegistroDTO dto) {
    return http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
  }
}