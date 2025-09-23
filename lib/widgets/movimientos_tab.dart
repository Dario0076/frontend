import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/movimientos_api_service.dart';
import '../services/productos_api_service.dart';
import '../services/usuario_service.dart';
import '../utils/export_excel.dart';

class MovimientosTab extends StatefulWidget {
  const MovimientosTab({super.key});

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
  // Filtros
  int? _filtroProductoId;
  DateTime? _filtroFechaInicio;
  DateTime? _filtroFechaFin;

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
      final productosData = await ProductosApiService.getProductos();
      List<Movimiento> movimientosData = [];
      // Lógica de filtros
      if (_filtroProductoId != null &&
          _filtroFechaInicio != null &&
          _filtroFechaFin != null) {
        movimientosData =
            await MovimientosApiService.getMovimientosByProductoAndFecha(
              _filtroProductoId!,
              _filtroFechaInicio!,
              _filtroFechaFin!,
            );
      } else if (_filtroProductoId != null) {
        movimientosData = await MovimientosApiService.getMovimientosByProducto(
          _filtroProductoId!,
        );
      } else if (_filtroFechaInicio != null && _filtroFechaFin != null) {
        movimientosData = await MovimientosApiService.getMovimientosByFecha(
          _filtroFechaInicio!,
          _filtroFechaFin!,
        );
      } else {
        movimientosData = await MovimientosApiService.getMovimientos();
      }
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

  // Métodos para seleccionar fechas
  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filtroFechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _filtroFechaInicio = picked;
      });
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filtroFechaFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _filtroFechaFin = picked;
      });
    }
  }

  Future<void> _createMovimiento() async {
    if (_cantidadController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _selectedProductoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
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
        SnackBar(content: Text(mensaje), duration: const Duration(seconds: 4)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear movimiento')),
      );
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

  Future<void> _exportarMovimientosPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Reporte de Movimientos',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                  'Tipo',
                  'Producto',
                  'Cantidad',
                  'Descripción',
                  'Usuario',
                  'Fecha',
                ],
                data: movimientos
                    .map(
                      (m) => [
                        m.tipoMovimiento,
                        _getProductoNombre(m.productoId),
                        m.cantidad.toString(),
                        m.descripcion,
                        (m.usuarioNombre ?? '') + ' ' + (m.usuarioEmail ?? ''),
                        m.fecha.toString().split('.')[0],
                      ],
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _exportarMovimientosExcel() async {
    final rows = [
      ['Tipo', 'Producto', 'Cantidad', 'Descripción', 'Usuario', 'Fecha'],
      ...movimientos.map(
        (m) => [
          m.tipoMovimiento,
          _getProductoNombre(m.productoId),
          m.cantidad,
          m.descripcion,
          (m.usuarioNombre ?? '') + ' ' + (m.usuarioEmail ?? ''),
          m.fecha.toString().split('.')[0],
        ],
      ),
    ];
    await exportarStockExcel(rows, context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Filtros de búsqueda (ExpansionTile)
          ExpansionTile(
            title: const Text(
              'Filtros de búsqueda',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: false,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    // Filtro producto
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _filtroProductoId,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por producto',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...productos.map((Producto producto) {
                            return DropdownMenuItem<int>(
                              value: producto.id,
                              child: Text(producto.nombre),
                            );
                          }).toList(),
                        ],
                        onChanged: (int? newValue) {
                          setState(() {
                            _filtroProductoId = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filtro fecha inicio
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectFechaInicio(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha inicio',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _filtroFechaInicio != null
                                ? _filtroFechaInicio!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]
                                : 'Todas',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filtro fecha fin
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectFechaFin(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha fin',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _filtroFechaFin != null
                                ? _filtroFechaFin!.toLocal().toString().split(
                                    ' ',
                                  )[0]
                                : 'Todas',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Filtrar'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar filtros',
                      onPressed: () {
                        setState(() {
                          _filtroProductoId = null;
                          _filtroFechaInicio = null;
                          _filtroFechaFin = null;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Formulario de creación (ExpansionTile)
          ExpansionTile(
            title: const Text(
              'Crear Movimiento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: false,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedTipoMovimiento,
                            decoration: const InputDecoration(
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _cantidadController,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedProductoId,
                            decoration: const InputDecoration(
                              labelText: 'Producto',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: productos.map((Producto producto) {
                              return DropdownMenuItem<int>(
                                value: producto.id,
                                child: Text(
                                  producto.nombre.length > 20
                                      ? '${producto.nombre.substring(0, 20)}...'
                                      : producto.nombre,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedProductoId = newValue;
                              });
                            },
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
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _createMovimiento,
                            child: const Text('Crear Movimiento'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Obtener Movimientos'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botones de exportación
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exportar PDF'),
                onPressed: movimientos.isEmpty ? null : _exportarMovimientosPDF,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.table_chart),
                label: const Text('Exportar Excel'),
                onPressed: movimientos.isEmpty
                    ? null
                    : _exportarMovimientosExcel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de movimientos
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : movimientos.isEmpty
                ? const Center(child: Text('No hay movimientos disponibles'))
                : ListView.builder(
                    itemCount: movimientos.length,
                    itemBuilder: (context, index) {
                      final movimiento = movimientos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 0,
                        ),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${movimiento.tipoMovimiento} - ${movimiento.cantidad} unidades',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Producto: ${_getProductoNombre(movimiento.productoId)}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                'Descripción: ${movimiento.descripcion}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                'Usuario: ${movimiento.usuarioNombre ?? 'No disponible'} (${movimiento.usuarioEmail ?? ''})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Fecha: ${movimiento.fecha.toString().split('.')[0]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
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
    _cantidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}
