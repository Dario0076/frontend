import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, String> serviceUrls = {
    'Movimiento': 'http://localhost:8088/movimientos/actuator/health',
    'Productos': 'http://localhost:8088/productos/actuator/health',
    'Stock': 'http://localhost:8088/stock/actuator/health',
    'Usuarios': 'http://localhost:8088/usuarios/actuator/health',
  };

  Map<String, bool> serviceStatus = {
    'Movimiento': false,
    'Productos': false,
    'Stock': false,
    'Usuarios': false,
  };

  @override
  void initState() {
    super.initState();
    _checkServices();
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkServices();
    });
  }

  Future<void> _checkServices() async {
    for (var entry in serviceUrls.entries) {
      try {
        final response = await http
            .get(Uri.parse(entry.value))
            .timeout(const Duration(seconds: 3));
        setState(() {
          serviceStatus[entry.key] = response.statusCode == 200;
        });
      } catch (_) {
        setState(() {
          serviceStatus[entry.key] = false;
        });
      }
    }
  }

  Widget _buildServiceStatusIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: serviceStatus.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Tooltip(
            message: entry.key,
            child: Icon(
              entry.value ? Icons.check_circle : Icons.cancel,
              color: entry.value ? Colors.green : Colors.red,
              size: 22,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? nombreUsuario =
        ModalRoute.of(context)?.settings.arguments as String?;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventario'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            _buildServiceStatusIcons(),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
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
              colors: [Color(0xFFF3F0F8), Color(0xFFEDE7F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nombreUsuario != null
                        ? '¡Bienvenido, $nombreUsuario!'
                        : 'Bienvenido al sistema de inventario',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    // Movimientos
                    _CrudTab(tabName: 'Movimientos'),
                    // Productos
                    _CrudTab(tabName: 'Productos'),
                    // Usuarios
                    _CrudTab(tabName: 'Usuarios'),
                    // Categorías
                    _CrudTab(tabName: 'Categorías'),
                    // Stock
                    _CrudTab(tabName: 'Stock'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrudTab extends StatelessWidget {
  final String tabName;
  const _CrudTab({required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text('Crear $tabName'),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Obtener'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: 5, // Simulación
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) => ListTile(
                leading: Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text('$tabName #${i + 1}'),
                subtitle: Text('Descripción de $tabName'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Eliminar',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
