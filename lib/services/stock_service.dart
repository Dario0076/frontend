import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class StockService {
  String get baseUrl => ApiConfig.stockBaseUrl;

  Future<http.Response> registrarStock(Map<String, dynamic> dto) async {
    try {
      print('=== DEBUG CREAR STOCK ===');
      print('URL: $baseUrl');
      print('DTO: ${jsonEncode(dto)}');
      print('=========================');

      return await http
          .post(
            Uri.parse(baseUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(dto),
          )
          .timeout(ApiConfig.timeout);
    } catch (e) {
      print('Error en createStock: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listarStock() async {
    try {
      print('=== DEBUG LISTAR STOCK ===');
      print('URL: $baseUrl');
      print('==========================');

      final response = await http
          .get(Uri.parse(baseUrl), headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.timeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Error al cargar stock - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en getStocks: $e');
      throw Exception('Error al cargar stock: $e');
    }
  }
}
