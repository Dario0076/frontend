import 'package:flutter/material.dart';
import '../models/categoria_registro_dto.dart';
import '../services/categoria_service.dart';

class RegistrarCategoriaPage extends StatefulWidget {
  const RegistrarCategoriaPage({super.key});

  @override
  _RegistrarCategoriaPageState createState() => _RegistrarCategoriaPageState();
}

class _RegistrarCategoriaPageState extends State<RegistrarCategoriaPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String descripcion = '';

  void registrarCategoria() async {
    if (_formKey.currentState!.validate()) {
      CategoriaRegistroDTO dto = CategoriaRegistroDTO(
        nombre: nombre,
        descripcion: descripcion,
      );
      await CategoriaService().registrarCategoria(dto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría registrada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Categoría')),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registrarCategoria,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}