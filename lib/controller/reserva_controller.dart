import 'package:finpay/model/sitema_reservas.dart';
import 'package:get/get.dart';
import 'package:finpay/api/api.service.dart';
import 'package:flutter/material.dart';

class ReservaController extends GetxController {
  final api = ApiService();
  RxList<Piso> pisos = <Piso>[].obs;
  Rx<Piso?> pisoSeleccionado = Rx<Piso?>(null);
  RxList<Lugar> lugaresDisponibles = <Lugar>[].obs;
  Rx<Lugar?> lugarSeleccionado = Rx<Lugar?>(null);
  Rx<DateTime?> horarioInicio = Rx<DateTime?>(null);
  Rx<DateTime?> horarioSalida = Rx<DateTime?>(null);
  Rx<int?> duracionSeleccionada = Rx<int?>(null);
  RxList<Auto> autosCliente = <Auto>[].obs;
  Rx<Auto?> autoSeleccionado = Rx<Auto?>(null);
  RxList<Reserva> reservasPendientes = <Reserva>[].obs;
  String codigoClienteActual = 'cliente_1';
  Rx<bool> esPorDias = false.obs;
  RxBool isReserving = false.obs;

  @override
  void onInit() {
    super.onInit();
    resetearCampos();
    cargarAutosDelCliente();
    cargarPisosYLugares();
    cargarReservasPendientes();
  }

  Future<void> cargarPisosYLugares() async {
    try {
      final rawPisos = await api.getPisos();
      final rawLugares = await api.getLugares();
      final rawReservas = await api.getReservas();

      final reservas = rawReservas.map((e) => Reserva.fromJson(e)).toList();
      final lugaresReservados = reservas.map((r) => r.codigoReserva).toSet();

      final todosLugares = rawLugares.map((e) => Lugar.fromJson(e)).toList();

      // Unir pisos con sus lugares correspondientes
      pisos.value = rawPisos.map((pJson) {
        final codigoPiso = pJson['codigo'];
        final lugaresDelPiso =
            todosLugares.where((l) => l.codigoPiso == codigoPiso).toList();

        return Piso(
          codigo: codigoPiso,
          descripcion: pJson['descripcion'],
          lugares: lugaresDelPiso,
        );
      }).toList();

      // Inicializar lugares disponibles (solo los no reservados)
      lugaresDisponibles.value = todosLugares.where((l) {
        return !lugaresReservados.contains(l.codigoLugar);
      }).toList();
    } catch (e) {
      print("Error al cargar datos: $e");
      Get.snackbar(
        "Error",
        "No se pudieron cargar los datos. Por favor, intenta nuevamente.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> seleccionarPiso(Piso piso) {
    pisoSeleccionado.value = piso;
    lugarSeleccionado.value = null;
    lugaresDisponibles.refresh();
    return Future.value();
  }

  Future<bool> confirmarReserva() async {
    if (pisoSeleccionado.value == null ||
        lugarSeleccionado.value == null ||
        horarioInicio.value == null ||
        horarioSalida.value == null ||
        autoSeleccionado.value == null) {
      return false;
    }

    isReserving.value = true;

    final duracionEnHoras =
        horarioSalida.value!.difference(horarioInicio.value!).inMinutes / 60;

    if (duracionEnHoras <= 0) {
      isReserving.value = false;
      return false;
    }

    final montoCalculado = (duracionEnHoras * 10000).roundToDouble();

    final nuevaReserva = Reserva(
      codigoReserva: "RES-${DateTime.now().millisecondsSinceEpoch}",
      horarioInicio: horarioInicio.value!,
      horarioSalida: horarioSalida.value!,
      monto: montoCalculado,
      estadoReserva: "PENDIENTE",
      chapaAuto: autoSeleccionado.value!.chapa,
    );

    try {
      // Crear la reserva en la API
      await api.crearReserva(nuevaReserva.toJson());
      
      // Actualizar el estado del lugar
      await api.actualizarEstadoLugar(
        lugarSeleccionado.value!.codigoLugar,
        "RESERVADO"
      );

      return true;
    } catch (e) {
      print("Error al guardar reserva: $e");
      Get.snackbar(
        "Error",
        "No se pudo crear la reserva. Por favor, intenta nuevamente.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      isReserving.value = false;
      return false;
    }
  }

  void resetearCampos() {
    pisoSeleccionado.value = null;
    lugarSeleccionado.value = null;
    horarioInicio.value = null;
    horarioSalida.value = null;
    duracionSeleccionada.value = null;
  }

  Future<void> cargarAutosDelCliente() async {
    try {
      final rawAutos = await api.getAutosCliente(codigoClienteActual);
      final autos = rawAutos.map((e) => Auto.fromJson(e)).toList();
      autosCliente.value = autos;
    } catch (e) {
      print("Error al cargar autos: $e");
      Get.snackbar(
        "Error",
        "No se pudieron cargar los vehículos. Por favor, intenta nuevamente.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> cargarReservasPendientes() async {
    try {
      final reservas = await api.getReservas();
      reservasPendientes.value = reservas
          .map((json) => Reserva.fromJson(json))
          .where((r) => r.estadoPago == "PENDIENTE")
          .toList();
    } catch (e) {
      print("Error al cargar reservas pendientes: $e");
    }
  }

  Future<bool> realizarPago(String codigoReserva) async {
    try {
      final reservas = await api.getReservas();
      final reserva = reservas.firstWhere((r) => r['codigoReserva'] == codigoReserva);
      
      // Crear el pago
      final pago = Pago(
        codigoPago: "PAG-${DateTime.now().millisecondsSinceEpoch}",
        codigoReservaAsociada: codigoReserva,
        montoPagado: reserva['monto'],
        fechaPago: DateTime.now(),
      );

      // Guardar el pago
      await api.crearPago(pago.toJson());

      // Actualizar estado de la reserva
      reserva['estadoPago'] = "PAGADO";
      await api.actualizarReserva(codigoReserva, reserva);

      // Recargar reservas pendientes
      await cargarReservasPendientes();

      return true;
    } catch (e) {
      print("Error al realizar el pago: $e");
      return false;
    }
  }

  @override
  void onClose() {
    resetearCampos();
    super.onClose();
  }
}
