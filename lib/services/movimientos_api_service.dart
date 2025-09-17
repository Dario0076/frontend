import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/usuario_service.dart';

/// Modelo de datos para un movimiento de inventario.
/// Incluye métodos para serializar/deserializar desde/hacia JSON.

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

  /// Crea una instancia de Movimiento a partir de un JSON.
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

  /// Convierte la instancia de Movimiento a un mapa JSON.
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

/// Servicio para interactuar con el microservicio de movimientos vía API REST.
/// Permite obtener, crear y consultar movimientos de inventario.
class MovimientosApiService {
  /// Devuelve la URL base del microservicio de movimientos.
  static String get baseUrl => ApiConfig.movimientosBaseUrl;

  /// Obtiene la lista de movimientos desde la API.
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
      return [];
    }
  }

  /// Crea un nuevo movimiento en la API.
  /// Incluye el ID del usuario logueado y la información de stock relacionada.
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

      final response = await http
          .post(
            Uri.parse(baseUrl), // Cambiar de '$baseUrl/simple' a solo 'baseUrl'
            headers: {'Content-Type': 'application/json'},
            body: json.encode(movimientoRegistroDTO),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al crear movimiento: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return null;
    }
  }

  /// Obtiene los movimientos asociados a un producto específico.
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
      return [];
    }
  }

  /// Obtiene los movimientos en un rango de fechas (formato: yyyy-MM-ddTHH:mm:ss)
  static Future<List<Movimiento>> getMovimientosByFecha(
    DateTime inicio,
    DateTime fin,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/fecha?inicio=${inicio.toIso8601String()}&fin=${fin.toIso8601String()}',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Movimiento.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al cargar movimientos por fecha: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtiene los movimientos de un producto en un rango de fechas
  static Future<List<Movimiento>> getMovimientosByProductoAndFecha(
    int productoId,
    DateTime inicio,
    DateTime fin,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/producto/$productoId/fecha?inicio=${inicio.toIso8601String()}&fin=${fin.toIso8601String()}',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Movimiento.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al cargar movimientos por producto y fecha: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }
}
