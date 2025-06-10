import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/model/auto_model.dart';
import 'package:finpay/model/sitema_reservas.dart';

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
  Future<List<Reserva>> getTodasLasReservas() async {
    final reservas = await _db.getAll("reservas.json");
    return reservas.map((json) => Reserva.fromJson(json)).toList();
  }

  // Obtener pagos previos
  Future<List<Pago>> getPagosPrevios() async {
    final pagos = await _db.getAll("pagos.json");
    return pagos.map((json) => Pago.fromJson(json)).toList();
  }

  // Obtener vehículos
  Future<List<Vehiculo>> getVehiculos() async {
    final vehiculos = await _db.getAll("autos.json");
    return vehiculos.map((json) => Vehiculo.fromJson(json)).toList();
  }

  // Agregar vehículo
  Future<Vehiculo?> agregarVehiculo(Vehiculo vehiculo) async {
    try {
      await _db.add("autos.json", vehiculo.toJson());
      return vehiculo;
    } catch (e) {
      print('Error al agregar vehículo: $e');
      return null;
    }
  }

  // Eliminar vehículo
  Future<bool> eliminarVehiculo(String chapa) async {
    try {
      await _db.delete("autos.json", chapa, "chapa");
      return true;
    } catch (e) {
      print('Error al eliminar vehículo: $e');
      return false;
    }
  }

  // Obtener autos de un cliente
  Future<List<Vehiculo>> getAutosCliente(String clienteId) async {
    final vehiculos = await getVehiculos();
    return vehiculos.where((v) => v.clienteId == clienteId).toList();
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