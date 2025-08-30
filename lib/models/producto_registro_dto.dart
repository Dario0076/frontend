class ProductoRegistroDTO {
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final int categoriaId;

  ProductoRegistroDTO({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.categoriaId,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'stock': stock,
    'categoriaId': categoriaId,
  };
}