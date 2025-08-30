class UsuarioRegistroDTO {
  final String nombre;
  final String correo;
  final String password;

  UsuarioRegistroDTO({
    required this.nombre,
    required this.correo,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'correo': correo,
    'password': password,
  };
}