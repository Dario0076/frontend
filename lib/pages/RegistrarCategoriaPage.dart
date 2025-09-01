import 'package:flutter/material.dart';
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
      Categoria categoria = Categoria(nombre: nombre, descripcion: descripcion);

      final result = await CategoriaService().crearCategoria(categoria);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría registrada exitosamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar categoría')),
        );
      }
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
