import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Flag para forzar uso de localhost (útil para testing con Postman)
  static bool _forceLocalhost = false;

  // Método para activar modo testing
  static void enableTestingMode() {
    _forceLocalhost = true;
  }

  // URLs base para cada servicio
  static String get usuariosBaseUrl {
    final url = '${_getBaseUrl()}:8083/api/usuarios';
    print('=== ApiConfig DEBUG ===');
    print('Usuario Base URL: $url');
    print('Platform: ${kIsWeb ? "WEB" : Platform.operatingSystem}');
    print('Testing Mode: $_forceLocalhost');
    print('======================');
    return url;
  }

  static String get productosBaseUrl => '${_getBaseUrl()}:8084/productos';
  static String get categoriasBaseUrl => '${_getBaseUrl()}:8084/categorias';
  static String get stockBaseUrl => '${_getBaseUrl()}:8081/stock';
  static String get movimientosBaseUrl => '${_getBaseUrl()}:8090/movimientos';

  // Detecta automáticamente la URL base según la plataforma
  static String _getBaseUrl() {
    // Si está en modo testing, siempre usar localhost
    if (_forceLocalhost) {
      return 'http://localhost';
    }

    if (kIsWeb) {
      // Para web usa localhost
      return 'http://localhost';
    } else if (Platform.isAndroid) {
      // Para emulador Android usa la IP para acceder al host
      return 'http://10.0.2.2';
    } else {
      return 'http://localhost';
    }
  }

  // Headers comunes para todas las peticiones
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout para todas las peticiones
  static const Duration timeout = Duration(seconds: 10);
}
