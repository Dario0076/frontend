import 'package:flutter/material.dart';
import 'package:frontend/services/usuarios_api_service.dart';

class UsuariosTab extends StatefulWidget {
  final String rolActual;
  const UsuariosTab({Key? key, required this.rolActual}) : super(key: key);

  @override
  State<UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<UsuariosTab> {
  List<Usuario> usuarios = [];
  List<Usuario> papelera = [];
  bool isLoading = true;
  // Estado para paneles contraíbles
  bool _activosExpanded = true;
  bool _papeleraExpanded = false;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    setState(() => isLoading = true);
    final todos = await UsuariosApiService.getUsuarios();
    setState(() {
      usuarios = todos.where((u) => u.activo).toList();
      papelera = todos.where((u) => !u.activo).toList();
      isLoading = false;
    });
  }

  void mostrarDialogoPassword(Usuario usuario) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar contraseña'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Nueva contraseña'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nueva = controller.text.trim();
              if (nueva.isNotEmpty && usuario.id != null) {
                final exito =
                    await UsuariosApiService.actualizarPasswordUsuario(
                      usuario.id!,
                      nueva,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      exito
                          ? 'Contraseña actualizada'
                          : 'Error al actualizar contraseña',
                    ),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void mostrarDialogoCrearUsuario() {
    final nombreCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String rol = 'USER';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Crear usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: correoCtrl,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              value: rol,
              items: const [
                DropdownMenuItem(value: 'USER', child: Text('Usuario')),
                DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
              ],
              onChanged: (v) => rol = v ?? 'USER',
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final correo = correoCtrl.text.trim();
              final pass = passCtrl.text.trim();
              if (nombre.isNotEmpty && correo.isNotEmpty && pass.isNotEmpty) {
                final nuevoUsuario = Usuario(
                  correo: correo,
                  nombreUsuario: nombre,
                  contrasena: pass,
                  rol: rol,
                  activo: true,
                );
                final creado = await UsuariosApiService.createUsuario(
                  nuevoUsuario,
                );
                Navigator.pop(context);
                if (creado != null) {
                  cargarUsuarios();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario creado')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al crear usuario')),
                  );
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void eliminarUsuario(Usuario usuario) async {
    if (usuario.id != null) {
      final exito = await UsuariosApiService.deleteUsuario(usuario.id!);
      cargarUsuarios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exito
                ? 'Usuario eliminado permanentemente'
                : 'Error al eliminar usuario',
          ),
        ),
      );
    }
  }

  void desactivarUsuario(Usuario usuario) async {
    if (usuario.id != null) {
      final actualizado = await UsuariosApiService.updateUsuario(
        Usuario(
          id: usuario.id,
          correo: usuario.correo,
          nombreUsuario: usuario.nombreUsuario,
          contrasena: usuario.contrasena,
          rol: usuario.rol,
          activo: false,
        ),
      );
      cargarUsuarios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            actualizado != null
                ? 'Usuario desactivado'
                : 'Error al desactivar usuario',
          ),
        ),
      );
    }
  }

  void reactivarUsuario(Usuario usuario) async {
    if (usuario.id != null) {
      final actualizado = await UsuariosApiService.updateUsuario(
        Usuario(
          id: usuario.id,
          correo: usuario.correo,
          nombreUsuario: usuario.nombreUsuario,
          contrasena: usuario.contrasena,
          rol: usuario.rol,
          activo: true,
        ),
      );
      cargarUsuarios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            actualizado != null
                ? 'Usuario reactivado'
                : 'Error al reactivar usuario',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.rolActual == 'ADMIN'
          ? FloatingActionButton(
              onPressed: mostrarDialogoCrearUsuario,
              tooltip: 'Crear usuario',
              child: const Icon(Icons.add),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        if (index == 0) {
                          _activosExpanded = !_activosExpanded;
                          if (_activosExpanded) _papeleraExpanded = false;
                        } else {
                          _papeleraExpanded = !_papeleraExpanded;
                          if (_papeleraExpanded) _activosExpanded = false;
                        }
                      });
                    },
                    children: [
                      ExpansionPanel(
                        headerBuilder: (context, isExpanded) => const ListTile(
                          title: Text(
                            'Usuarios Activos',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        isExpanded: _activosExpanded,
                        canTapOnHeader: true,
                        body: usuarios.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No hay usuarios activos'),
                              )
                            : Column(
                                children: usuarios
                                    .map(
                                      (u) => Card(
                                        child: ListTile(
                                          title: Text(u.nombreUsuario),
                                          subtitle: Text(
                                            '${u.correo} (${u.rol})',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (widget.rolActual == 'ADMIN')
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.lock_reset,
                                                  ),
                                                  tooltip: 'Editar contraseña',
                                                  onPressed: () =>
                                                      mostrarDialogoPassword(u),
                                                ),
                                              if (widget.rolActual == 'ADMIN')
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                  ),
                                                  tooltip: 'Desactivar usuario',
                                                  onPressed: () =>
                                                      desactivarUsuario(u),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                      ExpansionPanel(
                        headerBuilder: (context, isExpanded) => const ListTile(
                          title: Text(
                            'Papelera',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        isExpanded: _papeleraExpanded,
                        canTapOnHeader: true,
                        body: papelera.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('La papelera está vacía'),
                              )
                            : Column(
                                children: papelera
                                    .map(
                                      (u) => Card(
                                        color: Colors.grey[200],
                                        child: ListTile(
                                          title: Text(u.nombreUsuario),
                                          subtitle: Text(
                                            '${u.correo} (${u.rol})',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.restore),
                                                tooltip: 'Restaurar usuario',
                                                onPressed: () =>
                                                    reactivarUsuario(u),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_forever,
                                                ),
                                                tooltip:
                                                    'Eliminar permanentemente',
                                                onPressed: () =>
                                                    eliminarUsuario(u),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
    // (Eliminado: las variables ya existen como campos de la clase)
  }
}
