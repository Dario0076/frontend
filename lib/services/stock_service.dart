import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  final String baseUrl = 'http://localhost:8081/stock';

  Future<http.Response> registrarStock(Map<String, dynamic> dto) {
    return http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto),
    );
  }

  Future<List<Map<String, dynamic>>> listarStock() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar stock');
    }
  }
}
