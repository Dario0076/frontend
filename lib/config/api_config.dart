import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // URLs base para cada servicio
  static String get usuariosBaseUrl => '${_getBaseUrl()}:8083/api/usuarios';
  static String get productosBaseUrl => '${_getBaseUrl()}:8084/productos';
  static String get stockBaseUrl => '${_getBaseUrl()}:8081/stock';
  static String get movimientosBaseUrl => '${_getBaseUrl()}:8090/movimientos';

  // Detecta automáticamente la URL base según la plataforma
  static String _getBaseUrl() {
    if (kIsWeb) {
      // Para web usa localhost
      return 'http://localhost';
    } else if (Platform.isAndroid) {
      // Para emulador Android usa la IP especial para acceder al host
      return 'http://10.0.2.2';
    } else if (Platform.isIOS) {
      // Para simulador iOS usa localhost
      return 'http://localhost';
    } else {
      // Para otras plataformas usa localhost por defecto
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
