class Movimiento {
  final int stockId;
  final int cantidad;
  final String tipo;
  final DateTime fecha;

  Movimiento({required this.stockId, required this.cantidad, required this.tipo, required this.fecha});

  factory Movimiento.fromJson(Map<String, dynamic> json) => Movimiento(
    stockId: json['stockId'],
    cantidad: json['cantidad'],
    tipo: json['tipo'],
    fecha: DateTime.parse(json['fecha']),
  );

  Map<String, dynamic> toJson() => {
    'stockId': stockId,
    'cantidad': cantidad,
    'tipo': tipo,
    'fecha': fecha.toIso8601String(),
  };
}

class Stock {
  final int id;
  final int cantidad;
  final int umbralMinimo;

  Stock({required this.id, required this.cantidad, required this.umbralMinimo});

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
    id: json['id'],
    cantidad: json['cantidad'],
    umbralMinimo: json['umbralMinimo'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cantidad': cantidad,
    'umbralMinimo': umbralMinimo,
  };
}

class MovimientoRegistroDTO {
  final Movimiento movimiento;
  final Stock stock;
  final int usuarioId;

  MovimientoRegistroDTO({required this.movimiento, required this.stock, required this.usuarioId});

  Map<String, dynamic> toJson() => {
    'movimiento': movimiento.toJson(),
    'stock': stock.toJson(),
    'usuarioId': usuarioId,
  };
}