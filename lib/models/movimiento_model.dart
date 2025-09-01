class Movimiento {
  final int id;
  final int productoId;
  final String tipo;
  final int cantidad;
  final DateTime fecha;
  final String motivo;

  Movimiento({
    required this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    required this.motivo,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'] ?? 0,
      productoId: json['productoId'] ?? 0,
      tipo: json['tipo'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      motivo: json['motivo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productoId': productoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'motivo': motivo,
    };
  }
}
