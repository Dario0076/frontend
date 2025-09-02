import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/usuario_service.dart';

class Movimiento {
  final int? id;
  final String tipoMovimiento;
  final int cantidad;
  final DateTime fecha;
  final String descripcion;
  final int productoId;
  final String? nombreProducto;
  final String? usuarioNombre;
  final String? usuarioEmail;

  Movimiento({
    this.id,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.fecha,
    required this.descripcion,
    required this.productoId,
    this.nombreProducto,
    this.usuarioNombre,
    this.usuarioEmail,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      tipoMovimiento: json['tipo'] ?? '', // Cambiar 'tipoMovimiento' por 'tipo'
      cantidad: json['cantidad'] ?? 0,
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      descripcion: json['descripcion'] ?? '',
      productoId: json['productoId'] ?? 0,
      nombreProducto: json['nombreProducto'],
      usuarioNombre: json['usuario'], // Mapear 'usuario' del backend
      usuarioEmail: json['usuarioEmail'], // Mapear 'usuarioEmail' del backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo':
          tipoMovimiento, // Cambiar 'tipoMovimiento' por 'tipo' para el backend
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'usuarioNombre': usuarioNombre,
      'usuarioEmail': usuarioEmail,
    };
  }
}

class MovimientosApiService {
  static const String baseUrl = 'http://localhost:8090/movimientos';

  static Future<List<Movimiento>> getMovimientos() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Movimiento.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar movimientos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getMovimientos: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createMovimiento(
    Movimiento movimiento,
  ) async {
    try {
      // Obtener el ID del usuario logueado
      final usuarioService = UsuarioService();
      final usuarioId = await usuarioService.getUsuarioId();

      if (usuarioId == null) {
        throw Exception('No se pudo obtener el ID del usuario logueado');
      }

      // Crear el DTO que espera el backend
      final movimientoRegistroDTO = {
        'movimiento': movimiento.toJson(),
        'stock': {
          'id': movimiento.productoId,
          'productoId': movimiento.productoId,
          'cantidad': movimiento.cantidad,
        },
        'usuarioId': usuarioId, // Usar el ID real del usuario
      };

      final response = await http.post(
        Uri.parse(baseUrl), // Cambiar de '$baseUrl/simple' a solo 'baseUrl'
        headers: {'Content-Type': 'application/json'},
        body: json.encode(movimientoRegistroDTO),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al crear movimiento: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error en createMovimiento: $e');
      return null;
    }
  }

  static Future<List<Movimiento>> getMovimientosByProducto(
    int productoId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/producto/$productoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Movimiento.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al cargar movimientos por producto: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en getMovimientosByProducto: $e');
      return [];
    }
  }
}
