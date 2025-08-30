import 'package:flutter/material.dart';
import '../services/stock_service.dart';

class RegistrarStockPage extends StatefulWidget {
  const RegistrarStockPage({super.key});

  @override
  _RegistrarStockPageState createState() => _RegistrarStockPageState();
}

class _RegistrarStockPageState extends State<RegistrarStockPage> {
  final _formKey = GlobalKey<FormState>();
  String productoId = '';
  String cantidad = '';

  void registrarStock() async {
    if (_formKey.currentState!.validate()) {
      await StockService().registrarStock({
        'productoId': productoId,
        'cantidad': int.parse(cantidad),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock registrado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Stock')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID Producto'),
                onChanged: (v) => productoId = v,
                validator: (v) => v!.isEmpty ? 'Ingrese ID de producto' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                onChanged: (v) => cantidad = v,
                validator: (v) => v!.isEmpty ? 'Ingrese cantidad' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registrarStock,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}