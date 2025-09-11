import 'package:flutter/material.dart';
import '../services/productos_api_service.dart';
import '../services/categoria_service.dart';

class ProductosTab extends StatefulWidget {
  const ProductosTab({super.key});

  @override
  _ProductosTabState createState() => _ProductosTabState();
}

class _ProductosTabState extends State<ProductosTab> {
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];
  List<Categoria> categorias = [];
  bool isLoading = true;
  bool _showCreateForm = false;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoria;
  int? _selectedCategoriaId;

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _loadCategorias();
  }

  void _filtrarProductos() {
    setState(() {
      productosFiltrados = productos.where((producto) {
        // Filtro por categoría
        bool cumpleFiltroCategoria =
            _selectedCategoriaId == null ||
            producto.categoria?.id == _selectedCategoriaId;

        // Filtro por texto de búsqueda
        bool cumpleFiltroTexto =
            _searchController.text.isEmpty ||
            producto.nombre.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            producto.descripcion.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        return cumpleFiltroCategoria && cumpleFiltroTexto;
      }).toList();
    });
  }

  Future<void> _loadCategorias() async {
    try {
      final categoriasData = await CategoriaService().listarCategorias();
      setState(() {
        categorias = categoriasData;
      });
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }

  Future<void> _loadProductos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final productosData = await ProductosApiService.getProductos();
      setState(() {
        productos = productosData;
        productosFiltrados = productosData;
        isLoading = false;
      });
      _filtrarProductos();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar productos: $e')));
    }
  }

  Future<void> _createProducto() async {
    if (_nombreController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _selectedCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Buscar la categoría completa basada en el nombre seleccionado
    final categoriaSeleccionada = categorias.firstWhere(
      (cat) => cat.nombre == _selectedCategoria,
      orElse: () => Categoria(nombre: _selectedCategoria!, descripcion: ''),
    );

    final producto = Producto(
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
      precio: double.tryParse(_precioController.text) ?? 0.0,
      cantidad: int.tryParse(_cantidadController.text),
      categoria: categoriaSeleccionada,
    );

    final createdProducto = await ProductosApiService.createProducto(producto);

    if (createdProducto != null) {
      _nombreController.clear();
      _descripcionController.clear();
      _precioController.clear();
      _cantidadController.clear();
      setState(() {
        _selectedCategoria = null;
      });
      _loadProductos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto creado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al crear producto')));
    }
  }

  Future<void> _deleteProducto(int id) async {
    final success = await ProductosApiService.deleteProducto(id);

    if (success) {
      _loadProductos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar producto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Filtros compactos
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Buscar producto',
                            hintText: 'Nombre...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) => _filtrarProductos(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<int>(
                          value: _selectedCategoriaId,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text(
                                'Todas',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ...categorias.map((categoria) {
                              return DropdownMenuItem<int>(
                                value: categoria.id,
                                child: Text(
                                  categoria.nombre,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoriaId = value;
                            });
                            _filtrarProductos();
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 36,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _selectedCategoriaId = null;
                            });
                            _filtrarProductos();
                          },
                          icon: const Icon(Icons.clear, size: 18),
                          tooltip: 'Limpiar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          'Mostrando ${productosFiltrados.length} de ${productos.length} productos',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showCreateForm = !_showCreateForm;
                            });
                          },
                          icon: Icon(
                            _showCreateForm ? Icons.expand_less : Icons.add,
                            size: 16,
                          ),
                          label: Text(
                            _showCreateForm ? 'Ocultar' : 'Crear',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Formulario de creación (colapsable)
          if (_showCreateForm)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Producto',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _precioController,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cantidadController,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategoria,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: categorias.map((categoria) {
                              return DropdownMenuItem<String>(
                                value: categoria.nombre,
                                child: Text(categoria.nombre),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategoria = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _createProducto,
                          icon: const Icon(Icons.save),
                          label: const Text('Crear'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _loadProductos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualizar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (_showCreateForm) const SizedBox(height: 8),
          // Lista de productos
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : productosFiltrados.isEmpty
                ? Center(
                    child: Text(
                      productos.isEmpty
                          ? 'No hay productos disponibles'
                          : 'No se encontraron productos con los filtros aplicados',
                    ),
                  )
                : ListView.builder(
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 4,
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            producto.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.descripcion,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Precio: \$${producto.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Categoría: ${producto.categoria?.nombre ?? 'Sin categoría'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => producto.id != null
                                ? _deleteProducto(producto.id!)
                                : null,
                          ),
                        ),
                      );
                    },
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
    _precioController.dispose();
    _cantidadController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
