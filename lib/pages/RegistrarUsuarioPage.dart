import 'package:flutter/material.dart';
import '../models/usuario_registro_dto.dart';
import '../services/usuario_service.dart';

class RegistrarUsuarioPage extends StatefulWidget {
  const RegistrarUsuarioPage({super.key});

  @override
  _RegistrarUsuarioPageState createState() => _RegistrarUsuarioPageState();
}

class _RegistrarUsuarioPageState extends State<RegistrarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String correo = '';
  String password = '';

  void registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      UsuarioRegistroDTO dto = UsuarioRegistroDTO(
        nombre: nombre,
        correo: correo,
        password: password,
      );
      await UsuarioService().registrarUsuario(dto);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario registrado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Usuario')),
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
                decoration: const InputDecoration(labelText: 'Correo'),
                onChanged: (v) => correo = v,
                validator: (v) => v!.isEmpty ? 'Ingrese correo' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) => v!.isEmpty ? 'Ingrese contraseña' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registrarUsuario,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
