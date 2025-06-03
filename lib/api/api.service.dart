import 'package:finpay/api/local.db.service.dart';

class ApiService {
  final LocalDBService _db = LocalDBService();
  
  // Obtener todos los pisos
  Future<List<Map<String, dynamic>>> getPisos() async {
    return await _db.getAll("pisos.json");
  }

  // Obtener todos los lugares
  Future<List<Map<String, dynamic>>> getLugares() async {
    return await _db.getAll("lugares.json");
  }

  // Obtener todas las reservas
  Future<List<Map<String, dynamic>>> getReservas() async {
    return await _db.getAll("reservas.json");
  }

  // Obtener autos de un cliente
  Future<List<Map<String, dynamic>>> getAutosCliente(String clienteId) async {
    final autos = await _db.getAll("autos.json");
    return autos.where((auto) => auto['clienteId'] == clienteId).toList();
  }

  // Crear una nueva reserva
  Future<Map<String, dynamic>> crearReserva(Map<String, dynamic> reserva) async {
    await _db.add("reservas.json", reserva);
    return reserva;
  }

  // Actualizar estado de un lugar
  Future<void> actualizarEstadoLugar(String codigoLugar, String estado) async {
    final lugares = await _db.getAll("lugares.json");
    final lugar = lugares.firstWhere((l) => l['codigoLugar'] == codigoLugar);
    lugar['estado'] = estado;
    await _db.update("lugares.json", "codigoLugar", codigoLugar, lugar);
  }

  // Crear un nuevo pago
  Future<Map<String, dynamic>> crearPago(Map<String, dynamic> pago) async {
    await _db.add("pagos.json", pago);
    return pago;
  }

  // Actualizar una reserva
  Future<void> actualizarReserva(String codigoReserva, Map<String, dynamic> reserva) async {
    await _db.update("reservas.json", "codigoReserva", codigoReserva, reserva);
  }
} 