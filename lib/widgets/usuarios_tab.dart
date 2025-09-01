import 'package:flutter/material.dart';
import '../services/usuarios_api_service.dart';

class UsuariosTab extends StatefulWidget {
  @override
  _UsuariosTabState createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<UsuariosTab> {
  List<Usuario> usuarios = [];
  bool isLoading = true;
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  String _selectedRol = 'USER';

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    setState(() {
      isLoading = true;
    });

    try {
      final usuariosData = await UsuariosApiService.getUsuarios();
      setState(() {
        usuarios = usuariosData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar usuarios: $e')));
    }
  }

  Future<void> _createUsuario() async {
    if (_correoController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final usuario = Usuario(
      correo: _correoController.text,
      nombreUsuario: _nombreController.text,
      contrasena: _contrasenaController.text,
      rol: _selectedRol,
    );

    // Usar admin@admin.com como email del admin para crear usuarios
    final createdUsuario = await UsuariosApiService.createUsuario(
      usuario,
      'admin@admin.com',
    );

    if (createdUsuario != null) {
      _correoController.clear();
      _nombreController.clear();
      _contrasenaController.clear();
      _selectedRol = 'USER';
      _loadUsuarios();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Usuario creado exitosamente')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear usuario')));
    }
  }

  Future<void> _deleteUsuario(int id) async {
    final success = await UsuariosApiService.deleteUsuario(id);

    if (success) {
      _loadUsuarios();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Usuario eliminado exitosamente')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar usuario')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Formulario de creación
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _correoController,
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre de Usuario',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _contrasenaController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRol,
                          decoration: InputDecoration(
                            labelText: 'Rol',
                            border: OutlineInputBorder(),
                          ),
                          items: ['USER', 'ADMIN'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRol = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _createUsuario,
                        child: Text('Crear Usuario'),
                      ),
                      ElevatedButton(
                        onPressed: _loadUsuarios,
                        child: Text('Obtener Usuarios'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Lista de usuarios
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : usuarios.isEmpty
                ? Center(child: Text('No hay usuarios disponibles'))
                : ListView.builder(
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final usuario = usuarios[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(usuario.nombreUsuario),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Correo: ${usuario.correo}'),
                              Text('Rol: ${usuario.rol}'),
                              Text(
                                'Estado: ${usuario.activo ? "Activo" : "Inactivo"}',
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => usuario.id != null
                                ? _deleteUsuario(usuario.id!)
                                : null,
                          ),
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
    _correoController.dispose();
    _nombreController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}
