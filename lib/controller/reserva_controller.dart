import 'package:finpay/model/sitema_reservas.dart';
import 'package:get/get.dart';
import 'package:finpay/api/api.service.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:flutter/material.dart';

class ReservaController extends GetxController {
  final api = ApiService();
  final HomeController homeController = Get.find<HomeController>();
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
      final reservas = await api.getTodasLasReservas();

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

  Future<void> seleccionarLugar(Lugar lugar) {
    lugarSeleccionado.value = lugar;
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

    // Verificar si el lugar está disponible para la fecha seleccionada
    if (!await _verificarDisponibilidadLugar()) {
      Get.snackbar(
        "Error",
        "El lugar seleccionado no está disponible para la fecha y hora seleccionadas.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
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
      // Recargar todas las reservas para actualizar el contador de pagos pendientes
      await homeController.cargarTodasLasReservas();

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

  Future<bool> _verificarDisponibilidadLugar() async {
    try {
      final todasLasReservas = await api.getTodasLasReservas();
      final reservasDelLugar = todasLasReservas.where((reserva) => 
        reserva.chapaAuto == lugarSeleccionado.value!.codigoLugar &&
        reserva.estadoReserva != "CANCELADO"
      ).toList();

      // Verificar si hay solapamiento con las reservas existentes
      for (var reserva in reservasDelLugar) {
        // Si la nueva reserva comienza antes de que termine una existente
        // o termina después de que comience una existente
        if ((horarioInicio.value!.isBefore(reserva.horarioSalida) && 
             horarioSalida.value!.isAfter(reserva.horarioInicio))) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print("Error al verificar disponibilidad: $e");
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
      final vehiculos = await api.getVehiculos();
      final autos = vehiculos.map((v) => v.toAuto()).toList().cast<Auto>();
      autosCliente.value = autos;
      update(); // Asegurarse de que la UI se actualice
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
      final reservas = await api.getTodasLasReservas();
      reservasPendientes.value = reservas
          .where((r) => r.estadoPago == "PENDIENTE")
          .toList();
    } catch (e) {
      print("Error al cargar reservas pendientes: $e");
    }
  }

  Future<bool> realizarPago(String codigoReserva) async {
    try {
      final reservas = await api.getTodasLasReservas();
      final reserva = reservas.firstWhere((r) => r.codigoReserva == codigoReserva);
      
      // Crear el pago
      final pago = Pago(
        codigoPago: "PAG-${DateTime.now().millisecondsSinceEpoch}",
        codigoReservaAsociada: codigoReserva,
        montoPagado: reserva.monto,
        fechaPago: DateTime.now(),
      );

      // Guardar el pago
      await api.crearPago(pago.toJson());

      // Actualizar estado de la reserva
      final reservaActualizada = reserva;
      reservaActualizada.estadoPago = "PAGADO";
      await api.actualizarReserva(codigoReserva, reservaActualizada.toJson());

      // Recargar reservas pendientes
      await cargarReservasPendientes();
      final HomeController homeController = Get.find();
      await homeController.cargarTodasLasReservas();
      await homeController.cargarPagosPrevios();

      return true;
    } catch (e) {
      print("Error al realizar el pago: $e");
      return false;
    }
  }

  Future<bool> cancelarReserva(String codigoReserva) async {
    try {
      final reservas = await api.getTodasLasReservas();
      final reservaIndex = reservas.indexWhere((r) => r.codigoReserva == codigoReserva);

      if (reservaIndex != -1) {
        final reservaACancelar = reservas[reservaIndex];
        reservaACancelar.estadoPago = "CANCELADO";
        await api.actualizarReserva(codigoReserva, reservaACancelar.toJson());

        // Recargar reservas pendientes y todas las reservas en Home para actualizar contadores
        await cargarReservasPendientes();
        final HomeController homeController = Get.find();
        await homeController.cargarTodasLasReservas();
        await homeController.cargarPagosPrevios(); // Also refresh monthly payments

        return true;
      }
      return false;
    } catch (e) {
      print("Error al cancelar reserva: $e");
      return false;
    }
  }

  @override
  void onClose() {
    resetearCampos();
    super.onClose();
  }
}
