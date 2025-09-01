import 'package:flutter/material.dart';
import '../widgets/stock_tab.dart';
import '../widgets/productos_tab.dart';
import '../widgets/usuarios_tab.dart';
import '../widgets/movimientos_tab.dart';
import '../widgets/categorias_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final String? nombreUsuario =
        ModalRoute.of(context)?.settings.arguments as String?;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            nombreUsuario != null
                ? 'Bienvenido, $nombreUsuario'
                : 'Sistema de Inventario',
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8F9FA), Color(0xFFE8F0FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: TabBarView(
            children: [
              MovimientosTab(),
              ProductosTab(),
              UsuariosTab(),
              CategoriasTab(),
              StockTab(),
            ],
          ),
        ),
      ),
    );
  }
}
