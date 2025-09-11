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
  static String get usuariosBaseUrl => '${_getBaseUrl()}:8083/api/usuarios';

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
      // Detectar si es emulador o dispositivo físico
      return _isEmulator() ? 'http://10.0.2.2' : 'http://192.168.1.6';
    } else {
      return 'http://localhost';
    }
  }

  // Detecta si está corriendo en emulador Android
  static bool _isEmulator() {
    // Método simple: verificar características típicas del emulador
    return Platform.environment['ANDROID_EMULATOR'] != null ||
        Platform.environment['ANDROID_AVD'] != null ||
        Platform.environment.containsKey('AVD_NAME') ||
        _hasEmulatorCharacteristics();
  }

  // Verifica características del emulador
  static bool _hasEmulatorCharacteristics() {
    try {
      // En emuladores, estos valores suelen estar presentes
      final model = Platform.environment['ro.product.model'] ?? '';
      final device = Platform.environment['ro.product.device'] ?? '';
      final hardware = Platform.environment['ro.hardware'] ?? '';

      return model.toLowerCase().contains('emulator') ||
          model.toLowerCase().contains('sdk') ||
          device.toLowerCase().contains('emulator') ||
          device.toLowerCase().contains('sdk') ||
          hardware.toLowerCase().contains('goldfish') ||
          hardware.toLowerCase().contains('ranchu');
    } catch (e) {
      // Si falla la detección, asumir dispositivo físico para usar IP real
      return false;
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
