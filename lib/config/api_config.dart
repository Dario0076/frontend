import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Flag para forzar uso de localhost (útil para testing local)
  static bool _useLocalhost = false;

  // Método para activar modo local (solo para desarrollo)
  static void enableLocalMode() {
    _useLocalhost = true;
  }

  // URLs de producción en Render
  static const String _prodUsuariosUrl = 'https://usuariosservice.onrender.com';
  static const String _prodProductosUrl =
      'https://productosservices.onrender.com';
  static const String _prodStockUrl = 'https://stockservice-wki5.onrender.com';
  static const String _prodMovimientosUrl =
      'https://movimientoservice-rdi7.onrender.com';

  // URLs base para cada servicio
  static String get usuariosBaseUrl => '${_getUsuariosUrl()}/api/usuarios';
  static String get productosBaseUrl => '${_getProductosUrl()}/productos';
  static String get categoriasBaseUrl => '${_getProductosUrl()}/categorias';
  static String get stockBaseUrl => '${_getStockUrl()}/stock';
  static String get movimientosBaseUrl => '${_getMovimientosUrl()}/movimientos';

  // Obtener URLs según el modo (producción vs desarrollo)
  static String _getUsuariosUrl() {
    if (_useLocalhost) return 'http://localhost:8083';
    return _prodUsuariosUrl;
  }

  static String _getProductosUrl() {
    if (_useLocalhost) return 'http://localhost:8084';
    return _prodProductosUrl;
  }

  static String _getStockUrl() {
    if (_useLocalhost) return 'http://localhost:8081';
    return _prodStockUrl;
  }

  static String _getMovimientosUrl() {
    if (_useLocalhost) return 'http://localhost:8090';
    return _prodMovimientosUrl;
  }

  // Headers por defecto para las requests
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout para las requests
  static const Duration timeout = Duration(seconds: 30);
}
