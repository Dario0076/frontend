class CategoriaRegistroDTO {
  final String nombre;
  final String descripcion;

  CategoriaRegistroDTO({
    required this.nombre,
    required this.descripcion,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
  };
}