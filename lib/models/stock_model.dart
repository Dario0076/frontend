class Stock {
  final int id;
  final int productoId;
  final int cantidadActual;
  final int umbralMinimo;
  final String? nombreProducto;

  Stock({
    required this.id,
    required this.productoId,
    required this.cantidadActual,
    required this.umbralMinimo,
    this.nombreProducto,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] ?? 0,
      productoId: json['productoId'] ?? 0,
      cantidadActual: json['cantidadActual'] ?? 0,
      umbralMinimo: json['umbralMinimo'] ?? 0,
      nombreProducto: json['nombreProducto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'productoId': productoId,
      'cantidadActual': cantidadActual,
      'umbralMinimo': umbralMinimo,
    };

    // Solo incluir el ID si no es 0 (para actualizaciones)
    if (id > 0) {
      json['id'] = id;
    }

    // Solo incluir nombreProducto si no es null
    if (nombreProducto != null) {
      json['nombreProducto'] = nombreProducto;
    }

    return json;
  }
}
