import 'package:flutter/material.dart';
import '../models/movimiento_registro_dto.dart';
import '../services/movimiento_service.dart';

class RegistrarMovimientoPage extends StatefulWidget {
  const RegistrarMovimientoPage({super.key});

  @override
  _RegistrarMovimientoPageState createState() =>
      _RegistrarMovimientoPageState();
}

class _RegistrarMovimientoPageState extends State<RegistrarMovimientoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _tipoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _stockIdController = TextEditingController();
  final _umbralMinimoController = TextEditingController();
  final _usuarioIdController = TextEditingController();

  final MovimientoService _service = MovimientoService();

  void _registrarMovimiento() async {
    if (_formKey.currentState!.validate()) {
      final movimiento = Movimiento(
        stockId: int.parse(_stockIdController.text),
        cantidad: int.parse(_cantidadController.text),
        tipo: _tipoController.text,
        fecha: DateTime.parse(_fechaController.text),
      );
      final stock = Stock(
        id: int.parse(_stockIdController.text),
        cantidad: int.parse(_cantidadController.text),
        umbralMinimo: int.parse(_umbralMinimoController.text),
      );
      final dto = MovimientoRegistroDTO(
        movimiento: movimiento,
        stock: stock,
        usuarioId: int.parse(_usuarioIdController.text),
      );
      final response = await _service.registrarMovimiento(dto);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Movimiento registrado')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al registrar')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Movimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _stockIdController,
                decoration: const InputDecoration(labelText: 'Stock ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo (ENTRADA/SALIDA)',
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha (YYYY-MM-DDTHH:MM:SS)',
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _umbralMinimoController,
                decoration: const InputDecoration(labelText: 'Umbral Mínimo'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _usuarioIdController,
                decoration: const InputDecoration(labelText: 'Usuario ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrarMovimiento,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
