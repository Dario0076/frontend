import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';
import '../config/api_config.dart';

class StockApiService {
  static String get baseUrl => ApiConfig.stockBaseUrl;

  static Future<List<Stock>> getStocks() async {
    try {
      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Stock.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener stocks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getStocks: $e');
      return [];
    }
  }

  static Future<Stock?> createStock(Stock stock) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(stock.toJson()),
          )
          .timeout(const Duration(seconds: 10));

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

  static Future<Stock?> updateStock(int id, Stock stock) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(stock.toJson()),
          )
          .timeout(const Duration(seconds: 10));

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

  static Future<bool> deleteStock(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error en deleteStock: $e');
      return false;
    }
  }
}
