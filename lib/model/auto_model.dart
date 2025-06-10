import 'package:finpay/model/sitema_reservas.dart';

class Vehiculo {
  final String chapa;
  final String marca;
  final String modelo;
  final String color;
  final String clienteId;

  Vehiculo({
    required this.chapa,
    required this.marca,
    required this.modelo,
    required this.color,
    this.clienteId = 'cliente_1', // Valor por defecto
  });

  Map<String, dynamic> toJson() {
    return {
      'chapa': chapa,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'clienteId': clienteId,
    };
  }

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      chapa: json['chapa'],
      marca: json['marca'],
      modelo: json['modelo'],
      color: json['color'] ?? '',
      clienteId: json['clienteId'] ?? 'cliente_1',
    );
  }

  // Convertir a Auto para compatibilidad
  Auto toAuto() {
    return Auto(
      chapa: chapa,
      marca: marca,
      modelo: modelo,
      chasis: chapa, // Usamos la chapa como chasis por ahora
      clienteId: clienteId,
    );
  }
} 