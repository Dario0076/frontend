import 'package:flutter/material.dart';
import '../models/producto_registro_dto.dart';
import '../services/producto_service.dart';

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
      ProductoRegistroDTO dto = ProductoRegistroDTO(
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        stock: stock,
        categoriaId: categoriaId,
      );
      await ProductoService().registrarProducto(dto);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto registrado')));
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
