import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'categoria_service.dart';

class Producto {
  final int? id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int? cantidad;
  final Categoria? categoria;
  final bool activo;

  Producto({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.cantidad,
    this.categoria,
    this.activo = true,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] ?? 0.0).toDouble(),
      cantidad: json['cantidad'] ?? 0,
      categoria: json['categoria'] != null
          ? (json['categoria'] is String
                ? Categoria(nombre: json['categoria'], descripcion: '')
                : Categoria.fromJson(json['categoria']))
          : null,
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'activo': activo,
    };
    if (cantidad != null) {
      map['cantidad'] = cantidad;
    }
    if (categoria != null) {
      map['categoria'] = categoria!.toJson();
    }
    return map;
  }
}

class ProductosApiService {
  static String get baseUrl => ApiConfig.productosBaseUrl;

  static Future<List<Producto>> getProductos() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getProductos: $e');
      return [];
    }
  }

  static Future<Producto?> getProductoById(int id) async {
    try {
      print('=== DEBUG GET PRODUCTO BY ID ===');
      print('URL: $baseUrl/$id');
      print('ID solicitado: $id');
      print('================================');

      final response = await http
          .get(Uri.parse('$baseUrl/$id'), headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.timeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return Producto.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener producto: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getProductoById: $e');
      return null;
    }
  }

  static Future<Producto?> createProducto(Producto producto) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(producto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Producto.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear producto: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createProducto: $e');
      return null;
    }
  }

  static Future<bool> deleteProducto(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error en deleteProducto: $e');
      return false;
    }
  }

  static Future<Producto?> updateProducto(Producto producto) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${producto.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(producto.toJson()),
      );

      if (response.statusCode == 200) {
        return Producto.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar producto: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateProducto: $e');
      return null;
    }
  }
}
