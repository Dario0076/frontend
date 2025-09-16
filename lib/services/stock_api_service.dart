import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';
import '../config/api_config.dart';

/// Servicio para interactuar con el microservicio de stock vía API REST.
/// Permite obtener, crear, actualizar y eliminar registros de stock.

class StockApiService {
  /// Devuelve la URL base del microservicio de stock.
  static String get baseUrl => ApiConfig.stockBaseUrl;

  /// Obtiene la lista de stocks desde la API.
  static Future<List<Stock>> getStocks() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.timeout); // Espera máxima para la respuesta

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Stock.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener stocks: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  /// Crea un nuevo registro de stock en la API.
  static Future<Stock?> createStock(Stock stock) async {
    try {
      final requestBody = json.encode(stock.toJson());

      // Debug: imprimir cuerpo y cabeceras de la petición
      print('Request Body: $requestBody');
      print('Headers: ${ApiConfig.defaultHeaders}');
      print('==========================');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: ApiConfig.defaultHeaders,
            body: requestBody,
          )
          .timeout(ApiConfig.timeout);

      // Debug: imprimir respuesta
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Stock.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear stock: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createStock: $e');
      return null;
    }
  }

  /// Actualiza un registro de stock existente en la API.
  static Future<Stock?> updateStock(int id, Stock stock) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$id'),
            headers: ApiConfig.defaultHeaders,
            body: json.encode(stock.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return Stock.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar stock: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateStock: $e');
      return null;
    }
  }

  /// Elimina un registro de stock por su ID en la API.
  static Future<bool> deleteStock(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$id'), headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.timeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error en deleteStock: $e');
      return false;
    }
  }
}
