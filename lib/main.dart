import 'package:flutter/material.dart';
import 'package:frontend/pages/RegistrarStockPage.dart';
import 'pages/HomePage.dart';
import 'pages/RegistrarMovimientoPage.dart';
import 'pages/RegistrarProductoPage.dart';
import 'pages/RegistrarUsuarioPage.dart';
import 'pages/RegistrarCategoriaPage.dart';
import 'pages/LoginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/': (context) => const HomePage(),
        '/movimientos': (context) => const RegistrarMovimientoPage(),
        '/productos': (context) => const RegistrarProductoPage(),
        '/usuarios': (context) => const RegistrarUsuarioPage(),
        '/categorias': (context) => const RegistrarCategoriaPage(),
        '/stock': (context) => const RegistrarStockPage(),
      },
    );
  }
}
