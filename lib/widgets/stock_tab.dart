import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/stock_api_service.dart';

class StockTab extends StatefulWidget {
  const StockTab({Key? key}) : super(key: key);

  @override
  State<StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  List<Stock> stocks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedStocks = await StockApiService.getStocks();
      if (mounted) {
        setState(() {
          stocks = loadedStocks;
          isLoading = false;
        });
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
                label: const Text('Crear Stock'),
                onPressed: _showCreateDialog,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
                onPressed: _loadStocks,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : stocks.isEmpty
                ? const Center(
                    child: Text(
                      'No hay stocks disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: stocks.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final stock = stocks[index];
                      return ListTile(
                        leading: Icon(
                          Icons.inventory,
                          color: stock.cantidadActual <= stock.umbralMinimo
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          stock.nombreProducto != null
                              ? '${stock.nombreProducto} (ID: ${stock.productoId})'
                              : 'Producto ID: ${stock.productoId}',
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
                              onPressed: () {
                                // TODO: Implementar edición
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Funcionalidad de edición próximamente',
                                    ),
                                  ),
                                );
                              },
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
}
