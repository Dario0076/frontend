import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/producto_registro_dto.dart';
import '../models/stock_model.dart';
import '../services/producto_service.dart';
import '../services/stock_api_service.dart';

class RegistrarProductoPage extends StatefulWidget {
  const RegistrarProductoPage({super.key});

  @override
  _RegistrarProductoPageState createState() => _RegistrarProductoPageState();
}

class _RegistrarProductoPageState extends State<RegistrarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String descripcion = '';
  double precio = 0.0;
  int stock = 0;
  int categoriaId = 0; // Asumiendo una categoría por defecto

  void registrarProducto() async {
    if (_formKey.currentState!.validate()) {
      try {
        ProductoRegistroDTO dto = ProductoRegistroDTO(
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          stock: stock,
          categoriaId: categoriaId,
        );

        print('=== DEBUG CREAR PRODUCTO ===');
        print('Datos del producto: ${dto.toJson()}');
        print('=============================');

        final response = await ProductoService().registrarProducto(dto);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Producto creado exitosamente, ahora crear el stock
          final responseData = json.decode(response.body);
          final productoId = responseData['id'];

          if (productoId != null && stock > 0) {
            print('=== CREANDO STOCK AUTOMÁTICO ===');
            print('ProductoId: $productoId, Stock: $stock');
            print('================================');

            final stockData = Stock(
              id: 0,
              productoId: productoId,
              cantidadActual: stock,
              umbralMinimo: (stock * 0.2)
                  .round(), // 20% del stock como umbral mínimo
            );

            final createdStock = await StockApiService.createStock(stockData);

            if (createdStock != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto y stock registrados exitosamente'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Producto registrado, pero error al crear stock',
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto registrado exitosamente')),
            );
          }

          // Limpiar formulario
          _formKey.currentState!.reset();
          nombre = '';
          descripcion = '';
          precio = 0.0;
          stock = 0;
          categoriaId = 0;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al registrar producto: ${response.statusCode}',
              ),
            ),
          );
        }
      } catch (e) {
        print('Error en registrarProducto: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (v) => nombre = v,
                validator: (v) => v!.isEmpty ? 'Ingrese nombre' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (v) => descripcion = v,
                validator: (v) => v!.isEmpty ? 'Ingrese descripción' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                onChanged: (v) => precio = double.tryParse(v) ?? 0.0,
                validator: (v) => v!.isEmpty ? 'Ingrese precio' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                onChanged: (v) => stock = int.tryParse(v) ?? 0,
                validator: (v) => v!.isEmpty ? 'Ingrese stock' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID de Categoría'),
                keyboardType: TextInputType.number,
                onChanged: (v) => categoriaId = int.tryParse(v) ?? 0,
                validator: (v) => v!.isEmpty ? 'Ingrese ID de categoría' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registrarProducto,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
