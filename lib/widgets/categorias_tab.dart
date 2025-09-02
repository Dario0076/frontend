import 'package:flutter/material.dart';
import '../services/categoria_service.dart';

class CategoriasTab extends StatefulWidget {
  const CategoriasTab({super.key});

  @override
  _CategoriasTabState createState() => _CategoriasTabState();
}

class _CategoriasTabState extends State<CategoriasTab> {
  List<Categoria> categorias = [];
  bool isLoading = true;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    setState(() {
      isLoading = true;
    });

    try {
      final categoriasData = await CategoriaService().listarCategorias();
      setState(() {
        categorias = categoriasData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar categorías: $e')));
    }
  }

  Future<void> _createCategoria() async {
    if (_nombreController.text.isEmpty || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final categoria = Categoria(
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
    );

    final createdCategoria = await CategoriaService().crearCategoria(categoria);

    if (createdCategoria != null) {
      _nombreController.clear();
      _descripcionController.clear();
      _loadCategorias();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría creada exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al crear categoría')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Formulario para crear categoría
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Crear Nueva Categoría',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la Categoría',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _createCategoria,
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Categoría'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _loadCategorias,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refrescar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Lista de categorías
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Categorías Disponibles',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : categorias.isEmpty
                          ? const Center(
                              child: Text('No hay categorías disponibles'),
                            )
                          : ListView.separated(
                              itemCount: categorias.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final categoria = categorias[index];
                                return ListTile(
                                  leading: Icon(
                                    Icons.category,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  title: Text(categoria.nombre),
                                  subtitle: Text(categoria.descripcion),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // TODO: Implementar edición
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Función de editar en desarrollo',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          // TODO: Implementar eliminación
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Función de eliminar en desarrollo',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}
