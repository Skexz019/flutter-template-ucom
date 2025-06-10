// ignore_for_file: deprecated_member_use

import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/api/api.service.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/model/transaction_model.dart';
import 'package:finpay/model/auto_model.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final api = ApiService();
  List<TransactionModel> transactionList = List<TransactionModel>.empty().obs;
  RxBool isWeek = true.obs;
  RxBool isMonth = false.obs;
  RxBool isYear = false.obs;
  RxBool isAdd = false.obs;
  RxList<Pago> pagosPrevios = <Pago>[].obs;
  RxList<Reserva> todasLasReservas = <Reserva>[].obs;
  RxList<Vehiculo> vehiculos = <Vehiculo>[].obs;

  @override
  void onInit() {
    super.onInit();
    customInit();
  }

  customInit() async {
    await cargarPagosPrevios();
    await cargarTodasLasReservas();
    await cargarVehiculos();
    isWeek.value = true;
    isMonth.value = false;
    isYear.value = false;
    transactionList = [
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        DefaultImages.transaction4,
        "Apple Store",
        "iPhone 12 Case",
        "- \$120,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction3,
        "Ilya Vasil",
        "Wise • 5318",
        "- \$50,90",
        "05:39 AM",
      ),
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        "",
        "Burger King",
        "Cheeseburger XL",
        "- \$5,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction1,
        "Claudia Sarah",
        "Finpay Card • 5318",
        "- \$50,90",
        "04:39 AM",
      ),
    ];
  }

  Future<void> cargarPagosPrevios() async {
    try {
      final response = await api.getPagosPrevios();
      if (response != null) {
        pagosPrevios.value = response;
      }
    } catch (e) {
      print('Error al cargar pagos previos: $e');
    }
  }

  Future<void> cargarTodasLasReservas() async {
    try {
      final response = await api.getTodasLasReservas();
      if (response != null) {
        todasLasReservas.value = response;
      }
    } catch (e) {
      print('Error al cargar reservas: $e');
    }
  }

  Future<void> cargarVehiculos() async {
    try {
      final response = await api.getVehiculos();
      if (response != null) {
        vehiculos.value = response;
      }
    } catch (e) {
      print('Error al cargar vehículos: $e');
    }
  }

  Future<void> agregarVehiculo(Vehiculo vehiculo) async {
    try {
      final response = await api.agregarVehiculo(vehiculo);
      if (response != null) {
        vehiculos.add(vehiculo);
        // Actualizar la lista de vehículos en ReservaController si está registrado
        if (Get.isRegistered<ReservaController>()) {
          final reservaController = Get.find<ReservaController>();
          await reservaController.cargarAutosDelCliente();
        }
        update();
      }
    } catch (e) {
      print('Error al agregar vehículo: $e');
    }
  }

  Future<void> eliminarVehiculo(String chapa) async {
    try {
      final response = await api.eliminarVehiculo(chapa);
      if (response != null) {
        vehiculos.removeWhere((v) => v.chapa == chapa);
        update();
      }
    } catch (e) {
      print('Error al eliminar vehículo: $e');
    }
  }

  int getPagosDelMes() {
    final now = DateTime.now();
    return pagosPrevios.where((pago) => pago.fechaPago.month == now.month).length;
  }

  int getPagosPendientes() {
    return todasLasReservas.where((reserva) => reserva.estadoPago == "PENDIENTE").length;
  }
}
