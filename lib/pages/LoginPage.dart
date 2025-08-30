import 'package:flutter/material.dart';
import '../services/usuario_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String correo = '';
  String contrasena = '';
  bool cargando = false;
  String? error;

  void iniciarSesion() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final exito = await UsuarioService().login(correo, contrasena);
      if (exito) {
        // Navega a la pantalla principal
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          error = 'Credenciales incorrectas';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al iniciar sesión';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo'),
                onChanged: (v) => correo = v,
                validator: (v) => v!.isEmpty ? 'Ingrese correo' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onChanged: (v) => contrasena = v,
                validator: (v) => v!.isEmpty ? 'Ingrese contraseña' : null,
              ),
              const SizedBox(height: 20),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: cargando
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) iniciarSesion();
                      },
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text('Ingresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
