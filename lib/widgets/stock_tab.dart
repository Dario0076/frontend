import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as ex;
import 'dart:html' as html;
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/stock_model.dart';
import '../services/stock_api_service.dart';
import '../services/productos_api_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StockTab extends StatefulWidget {
  const StockTab({Key? key}) : super(key: key);

  @override
  State<StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  List<Stock> stocks = [];
  List<Stock> stocksFiltrados = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  void _filtrarStocks() {
    setState(() {
      stocksFiltrados = stocks.where((stock) {
        final searchText = _searchController.text.toLowerCase();

        if (searchText.isEmpty) {
          return true;
        }

        // Buscar por ID del producto
        if (stock.productoId.toString().contains(searchText)) {
          return true;
        }

        // Buscar por nombre del producto
        if (stock.nombreProducto != null &&
            stock.nombreProducto!.toLowerCase().contains(searchText)) {
          return true;
        }

        return false;
      }).toList();
    });
  }

  Future<void> _loadStocks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedStocks = await StockApiService.getStocks();

      // Obtener nombres de productos para cada stock
      for (int i = 0; i < loadedStocks.length; i++) {
        try {
          final producto = await ProductosApiService.getProductoById(
            loadedStocks[i].productoId,
          );
          if (producto != null) {
            // Crear nuevo Stock con el nombre del producto
            loadedStocks[i] = Stock(
              id: loadedStocks[i].id,
              productoId: loadedStocks[i].productoId,
              cantidadActual: loadedStocks[i].cantidadActual,
              umbralMinimo: loadedStocks[i].umbralMinimo,
              nombreProducto: producto.nombre,
            );
          }
        } catch (e) {
          print('Error al obtener producto ${loadedStocks[i].productoId}: $e');
          // Mantener el stock sin nombre si hay error
        }
      }

      if (mounted) {
        setState(() {
          stocks = loadedStocks;
          stocksFiltrados = loadedStocks;
          isLoading = false;
        });
        _filtrarStocks();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar stocks: $e')));
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final TextEditingController productoIdController = TextEditingController();
    final TextEditingController cantidadController = TextEditingController();
    final TextEditingController umbralController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productoIdController,
                decoration: const InputDecoration(labelText: 'ID del Producto'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad Actual'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: umbralController,
                decoration: const InputDecoration(labelText: 'Umbral Mínimo'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final stock = Stock(
                  id: 0, // Se generará automáticamente
                  productoId: int.tryParse(productoIdController.text) ?? 0,
                  cantidadActual: int.tryParse(cantidadController.text) ?? 0,
                  umbralMinimo: int.tryParse(umbralController.text) ?? 0,
                );

                final createdStock = await StockApiService.createStock(stock);

                if (createdStock != null) {
                  Navigator.of(context).pop();
                  _loadStocks();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stock creado exitosamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al crear stock')),
                  );
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(Stock stock) async {
    final TextEditingController umbralController = TextEditingController(
      text: stock.umbralMinimo.toString(),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Umbral Mínimo - ${stock.nombreProducto ?? 'Producto ${stock.productoId}'}',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información actual:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Cantidad actual: ${stock.cantidadActual}'),
                      Text('Umbral actual: ${stock.umbralMinimo}'),
                      if (stock.cantidadActual <= stock.umbralMinimo)
                        const Text(
                          '⚠️ STOCK BAJO',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: umbralController,
                  decoration: const InputDecoration(
                    labelText: 'Nuevo Umbral Mínimo',
                    border: OutlineInputBorder(),
                    helperText: 'Establece cuándo debe alertarse de stock bajo',
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final umbralValue = int.tryParse(umbralController.text);
                if (umbralValue != null && umbralValue >= 0) {
                  Navigator.of(context).pop();

                  final updatedStock = Stock(
                    id: stock.id,
                    productoId: stock.productoId,
                    cantidadActual: stock.cantidadActual,
                    umbralMinimo: umbralValue,
                    nombreProducto: stock.nombreProducto,
                  );

                  final result = await StockApiService.updateStock(
                    stock.id,
                    updatedStock,
                  );
                  if (result != null) {
                    _loadStocks();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Umbral mínimo actualizado a $umbralValue exitosamente',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al actualizar el umbral mínimo'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor ingresa un número válido (mayor o igual a 0)',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStock(Stock stock) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar el stock del producto ${stock.productoId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await StockApiService.deleteStock(stock.id);
      if (success) {
        _loadStocks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock eliminado exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar stock')),
        );
      }
    }
  }

  Future<void> _exportarStockPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Reporte de Stock',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Producto', 'Cantidad', 'Umbral Mínimo'],
                data: stocksFiltrados
                    .map(
                      (s) => [
                        s.nombreProducto ?? 'Producto ${s.productoId}',
                        s.cantidadActual.toString(),
                        s.umbralMinimo.toString(),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportación exitosa: PDF generado.')),
    );
  }

  Future<void> _exportarStockExcel() async {
    final excel = ex.Excel.createExcel();
    final sheet = excel['Stock'];
    sheet.appendRow(['Producto', 'Cantidad', 'Umbral Mínimo']);
    for (final s in stocksFiltrados) {
      sheet.appendRow([
        s.nombreProducto ?? 'Producto ${s.productoId}',
        s.cantidadActual,
        s.umbralMinimo,
      ]);
    }
    final bytes = excel.encode();
    if (kIsWeb) {
      // Web: descarga usando AnchorElement
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'stock.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exportación exitosa: archivo Excel descargado.'),
        ),
      );
    } else {
      // Móvil/escritorio: guardar en carpeta de documentos/descargas
      try {
        final directory = await path_provider
            .getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/stock.xlsx');
        if (bytes != null) {
          await file.writeAsBytes(bytes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Exportación exitosa: archivo guardado en ${file.path}',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No se pudo generar el archivo Excel.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar archivo: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar stock',
                    hintText: 'ID del producto o nombre...',
                  ),
                  onChanged: (value) => _filtrarStocks(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Crear Stock'),
                onPressed: _showCreateDialog,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
                onPressed: _loadStocks,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botones de exportación en la UI
          Row(
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Exportar PDF'),
                onPressed: stocksFiltrados.isEmpty ? null : _exportarStockPDF,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.table_chart),
                label: Text('Exportar Excel'),
                onPressed: stocksFiltrados.isEmpty ? null : _exportarStockExcel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : stocksFiltrados.isEmpty
                ? Center(
                    child: Text(
                      stocks.isEmpty
                          ? 'No hay stocks disponibles'
                          : 'No se encontraron stocks con la búsqueda aplicada',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: stocksFiltrados.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final stock = stocksFiltrados[index];
                      return ListTile(
                        title: Text(
                          stock.nombreProducto ??
                              'Producto ${stock.productoId}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad: ${stock.cantidadActual}'),
                            Text('Umbral mínimo: ${stock.umbralMinimo}'),
                            if (stock.cantidadActual <= stock.umbralMinimo)
                              const Text(
                                'STOCK BAJO',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',
                              onPressed: () => _showEditDialog(stock),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Eliminar',
                              onPressed: () => _deleteStock(stock),
                            ),
                          ],
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
    _searchController.dispose();
    super.dispose();
  }
}
