import 'dart:io';
import 'package:flutter/foundation.dart';

/// Configuración centralizada de URLs y headers para los servicios de la API.
/// Cambia automáticamente entre entorno local y producción.
class ApiConfig {
  static bool _useLocalhost = true;

  /// Activa el modo local
  static void enableLocalModse() {
    _useLocalhost = true;
  }

  // Métodos para obtener la URL base de cada microservicio
  static String get usuariosBaseUrl {
    final url = '${_getUsuariosUrl()}/api/usuarios';
    return url;
  }

  static String get productosBaseUrl => '${_getProductosUrl()}/productos';
  static String get categoriasBaseUrl => '${_getProductosUrl()}/categorias';
  static String get stockBaseUrl => '${_getStockUrl()}/stock';
  static String get movimientosBaseUrl => '${_getMovimientosUrl()}/movimientos';

  // Métodos internos para decidir si usar localhost o emulador Android
  static String _getUsuariosUrl() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8083';
    }
    return 'http://localhost:8083';
  }

  static String _getProductosUrl() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8084';
    }
    return 'http://localhost:8084';
  }

  static String _getStockUrl() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8081';
    }
    return 'http://localhost:8081';
  }

  static String _getMovimientosUrl() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8090';
    }
    return 'http://localhost:8090';
  }

  /// Headers por defecto para todas las peticiones HTTP
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Timeout por defecto para las peticiones HTTP
  static const Duration timeout = Duration(seconds: 10);
}
