import 'package:flutter/material.dart';
import '../services/movimientos_api_service.dart';
import '../services/productos_api_service.dart';
import '../services/usuario_service.dart';

class MovimientosTab extends StatefulWidget {
  @override
  _MovimientosTabState createState() => _MovimientosTabState();
}

class _MovimientosTabState extends State<MovimientosTab> {
  List<Movimiento> movimientos = [];
  List<Producto> productos = [];
  bool isLoading = true;
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _selectedTipoMovimiento = 'ENTRADA';
  int? _selectedProductoId;
  final UsuarioService _usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final movimientosData = await MovimientosApiService.getMovimientos();
      final productosData = await ProductosApiService.getProductos();
      setState(() {
        movimientos = movimientosData;
        productos = productosData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  Future<void> _createMovimiento() async {
    if (_cantidadController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _selectedProductoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Obtener información del usuario logueado
    final usuarioInfo = await _usuarioService.getUsuarioLogueado();

    final movimiento = Movimiento(
      tipoMovimiento: _selectedTipoMovimiento,
      cantidad: int.tryParse(_cantidadController.text) ?? 0,
      fecha: DateTime.now(),
      descripcion: _descripcionController.text,
      productoId: _selectedProductoId!,
      usuarioNombre: usuarioInfo['nombre'],
      usuarioEmail: usuarioInfo['correo'],
    );

    final createdMovimiento = await MovimientosApiService.createMovimiento(
      movimiento,
    );

    if (createdMovimiento != null) {
      _cantidadController.clear();
      _descripcionController.clear();
      _selectedTipoMovimiento = 'ENTRADA';
      _selectedProductoId = null;
      _loadData();

      // Mostrar información detallada del stock actualizado
      String mensaje = 'Movimiento creado exitosamente!';
      if (createdMovimiento['mensaje'] != null) {
        mensaje = createdMovimiento['mensaje'];
      }
      if (createdMovimiento['stockAnterior'] != null &&
          createdMovimiento['stockNuevo'] != null) {
        mensaje += '\nStock anterior: ${createdMovimiento['stockAnterior']}';
        mensaje += '\nStock nuevo: ${createdMovimiento['stockNuevo']}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), duration: Duration(seconds: 4)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear movimiento')));
    }
  }

  String _getProductoNombre(int productoId) {
    final producto = productos.firstWhere(
      (p) => p.id == productoId,
      orElse: () => Producto(
        nombre: 'Producto no encontrado',
        descripcion: '',
        precio: 0,
        categoria: null,
      ),
    );
    return producto.nombre;
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
                        child: DropdownButtonFormField<String>(
                          value: _selectedTipoMovimiento,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Movimiento',
                            border: OutlineInputBorder(),
                          ),
                          items: ['ENTRADA', 'SALIDA'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTipoMovimiento = newValue!;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
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
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedProductoId,
                          decoration: InputDecoration(
                            labelText: 'Producto',
                            border: OutlineInputBorder(),
                          ),
                          items: productos.map((Producto producto) {
                            return DropdownMenuItem<int>(
                              value: producto.id,
                              child: Text(producto.nombre),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedProductoId = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _createMovimiento,
                        child: Text('Crear Movimiento'),
                      ),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('Obtener Movimientos'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Lista de movimientos
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : movimientos.isEmpty
                ? Center(child: Text('No hay movimientos disponibles'))
                : ListView.builder(
                    itemCount: movimientos.length,
                    itemBuilder: (context, index) {
                      final movimiento = movimientos[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            '${movimiento.tipoMovimiento} - ${movimiento.cantidad} unidades',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Producto: ${_getProductoNombre(movimiento.productoId)}',
                              ),
                              Text('Descripción: ${movimiento.descripcion}'),
                              Text(
                                'Usuario: ${movimiento.usuarioNombre ?? 'No disponible'} (${movimiento.usuarioEmail ?? ''})',
                              ),
                              Text(
                                'Fecha: ${movimiento.fecha.toString().split('.')[0]}',
                              ),
                            ],
                          ),
                          // Eliminado el botón de borrar - los movimientos son inmutables
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
    _cantidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}
