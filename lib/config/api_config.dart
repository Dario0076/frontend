import 'dart:io';
import 'package:flutter/foundation.dart';

/// Configuración centralizada de URLs y headers para los servicios de la API.
/// Cambia automáticamente entre entorno local y producción.
class ApiConfig {
  // Usa localhost por defecto para desarrollo.
  // Cambia a false para forzar URLs de producción.
  static bool _useLocalhost = true;

  /// Activa el modo local
  static void enableLocalMode() {
    _useLocalhost = true;
  }

  // URLs base de los servicios en Render
  static const String _prodUsuariosUrl = 'https://usuariosservice.onrender.com';
  static const String _prodProductosUrl =
      'https://productosservices.onrender.com';
  static const String _prodStockUrl = 'https://stockservice-wki5.onrender.com';
  static const String _prodMovimientosUrl =
      'https://movimientoservice-rdi7.onrender.com';

  // Métodos para obtener la URL base de cada microservicio
  // Ejemplo de uso: ApiConfig.usuariosBaseUrl
  static String get usuariosBaseUrl {
    // Devuelve la URL base para el microservicio de usuarios
    final url = '${_getUsuariosUrl()}/api/usuarios';
    return url;
  }

  static String get productosBaseUrl =>
      '${_getProductosUrl()}/productos'; // URL base productos
  static String get categoriasBaseUrl =>
      '${_getProductosUrl()}/categorias'; // URL base categorías
  static String get stockBaseUrl => '${_getStockUrl()}/stock'; // URL base stock
  static String get movimientosBaseUrl =>
      '${_getMovimientosUrl()}/movimientos'; // URL base movimientos

  // Métodos internos para decidir si usar localhost o producción
  // Se usan en los getters de arriba
  static String _getUsuariosUrl() {
    // Devuelve la URL base de usuarios según el entorno
    if (_useLocalhost) {
      if (!kIsWeb && Platform.isAndroid) {
        // Android emulador usa 10.0.2.2 para localhost
        return 'http://10.0.2.2:8083';
      }
      return 'http://localhost:8083';
    }
    return _prodUsuariosUrl;
  }

  static String _getProductosUrl() {
    if (_useLocalhost) {
      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:8084';
      }
      return 'http://localhost:8084';
    }
    return _prodProductosUrl;
  }

  static String _getStockUrl() {
    if (_useLocalhost) {
      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:8081';
      }
      return 'http://localhost:8081';
    }
    return _prodStockUrl;
  }

  static String _getMovimientosUrl() {
    if (_useLocalhost) {
      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:8090';
      }
      return 'http://localhost:8090';
    }
    return _prodMovimientosUrl;
  }

  /// Headers por defecto para todas las peticiones HTTP
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Timeout por defecto para las peticiones HTTP
  static const Duration timeout = Duration(seconds: 10);
}
