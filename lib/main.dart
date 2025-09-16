// Importaciones principales de Flutter y de las páginas del sistema
import 'package:flutter/material.dart';
import 'package:frontend/pages/RegistrarStockPage.dart';
import 'pages/HomePage.dart';
import 'pages/RegistrarMovimientoPage.dart';
import 'pages/RegistrarProductoPage.dart';
import 'pages/RegistrarUsuarioPage.dart';
import 'pages/RegistrarCategoriaPage.dart';
import 'pages/LoginPage.dart';

/// Punto de entrada principal de la aplicación
void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación que configura el tema y las rutas
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la aplicación
      title: 'Sistema de Inventario',
      // Definición del tema visual principal
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
        ),
      ),
      // Ruta inicial de la app (pantalla de login)
      initialRoute: '/login',
      // Definición de rutas para navegación entre pantallas
      routes: {
        '/login': (context) => const LoginPage(),
        '/': (context) => const HomePage(),
        '/home': (context) => const HomePage(),
        '/movimientos': (context) => const RegistrarMovimientoPage(),
        '/productos': (context) => const RegistrarProductoPage(),
        '/usuarios': (context) => const RegistrarUsuarioPage(),
        '/categorias': (context) => const RegistrarCategoriaPage(),
        '/stock': (context) => const RegistrarStockPage(),
      },
    );
  }
}
