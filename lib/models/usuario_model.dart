class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'email': email, 'rol': rol};
  }
}
