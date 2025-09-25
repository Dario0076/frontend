// Importaciones de Flutter y de los widgets de cada módulo del sistema
import 'package:flutter/material.dart';
import '../widgets/stock_tab.dart';
import '../widgets/productos_tab.dart';
import '../widgets/usuarios_tab.dart';
import '../widgets/movimientos_tab.dart';
import '../widgets/categorias_tab.dart';
import '../services/usuario_service.dart';

/// Pantalla principal del sistema de inventario.
/// Muestra las pestañas para navegar entre los módulos principales.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String rolActual = 'USER';

  @override
  void initState() {
    super.initState();
    obtenerRol();
  }

  Future<void> obtenerRol() async {
    final usuario = await UsuarioService().getUsuarioLogueado();
    setState(() {
      rolActual = usuario['rol'] ?? 'USER';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recupera el nombre del usuario si fue enviado por argumentos
    final String? nombreUsuario =
        ModalRoute.of(context)?.settings.arguments as String?;
    return DefaultTabController(
      length: 5, // Número de pestañas principales
      child: Scaffold(
        appBar: AppBar(
          // Título dinámico según el usuario logueado
          title: Text(
            nombreUsuario != null
                ? 'Bienvenido, $nombreUsuario'
                : 'Sistema de Inventario',
          ),
          centerTitle: true,
          actions: [
            // Botón para cerrar sesión y volver al login
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
          // Barra de pestañas para navegar entre módulos
          bottom: const TabBar(
            isScrollable: false,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.swap_horiz), text: 'Movimientos'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'Productos'),
              Tab(icon: Icon(Icons.person), text: 'Usuarios'),
              Tab(icon: Icon(Icons.category), text: 'Categorías'),
              Tab(icon: Icon(Icons.inventory), text: 'Stock'),
            ],
          ),
        ),
        body: Container(
          // Fondo con gradiente para mejor estética
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8F9FA), Color(0xFFE8F0FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          // Cada pestaña muestra el widget correspondiente al módulo
          child: TabBarView(
            children: [
              const MovimientosTab(),
              const ProductosTab(),
              UsuariosTab(rolActual: rolActual),
              const CategoriasTab(),
              const StockTab(),
            ],
          ),
        ),
      ),
    );
  }
}
