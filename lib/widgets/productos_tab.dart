import 'package:flutter/material.dart';
import '../services/productos_api_service.dart';
import '../services/categoria_service.dart';

class ProductosTab extends StatefulWidget {
  @override
  _ProductosTabState createState() => _ProductosTabState();
}

class _ProductosTabState extends State<ProductosTab> {
  List<Producto> productos = [];
  List<Categoria> categorias = [];
  bool isLoading = true;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  String? _selectedCategoria;

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _loadCategorias();
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
        isLoading = false;
      });
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
        SnackBar(content: Text('Por favor completa todos los campos')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Producto creado exitosamente')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear producto')));
    }
  }

  Future<void> _deleteProducto(int id) async {
    final success = await ProductosApiService.deleteProducto(id);

    if (success) {
      _loadProductos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar producto')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Formulario de creación
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del Producto',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _precioController,
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cantidadController,
                          decoration: InputDecoration(
                            labelText: 'Cantidad',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategoria,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
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
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _createProducto,
                        child: Text('Crear Producto'),
                      ),
                      ElevatedButton(
                        onPressed: _loadProductos,
                        child: Text('Obtener Productos'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Lista de productos
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : productos.isEmpty
                ? Center(child: Text('No hay productos disponibles'))
                : ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final producto = productos[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(producto.nombre),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(producto.descripcion),
                              Text(
                                'Precio: \$${producto.precio.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Categoría: ${producto.categoria?.nombre ?? 'Sin categoría'}',
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
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
    super.dispose();
  }
}
