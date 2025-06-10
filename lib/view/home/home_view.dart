// ignore_for_file: deprecated_member_use

import 'package:card_swiper/card_swiper.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/model/auto_model.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:finpay/view/home/top_up_screen.dart';
import 'package:finpay/view/home/transfer_screen.dart';
import 'package:finpay/view/home/widget/circle_card.dart';
import 'package:finpay/view/home/widget/custom_card.dart';
import 'package:finpay/view/home/widget/transaction_list.dart';
import 'package:finpay/view/reservas/reservas_screen.dart';
import 'package:finpay/view/reservas/pagos_pendientes_screen.dart';
import 'package:finpay/view/autos/autos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController;

  const HomeView({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.isLightTheme == false
          ? const Color(0xff15141F)
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Buenos días",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                    ),
                    Text(
                      "Bienvenido",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 69,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6A609).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            DefaultImages.ranking,
                          ),
                          Text(
                            "Oro",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: const Color(0xffF6A609),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        DefaultImages.avatar,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? HexColor('#15141f')
                          : Theme.of(context).appBarTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: HexColor(AppTheme.primaryColorString!).withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pagos del mes",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).textTheme.bodySmall!.color,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Text(
                              homeController.pagosPrevios
                                  .where((pago) => pago.fechaPago.month == DateTime.now().month)
                                  .length
                                  .toString(),
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => PagosPendientesScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.isLightTheme == false
                            ? HexColor('#15141f')
                            : Theme.of(context).appBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HexColor(AppTheme.primaryColorString!).withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pagos pendientes",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                                homeController.todasLasReservas
                                    .where((reserva) => reserva.estadoPago == "PENDIENTE")
                                    .length
                                    .toString(),
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24,
                                    ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const VehiculosScreen(),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 500));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.isLightTheme == false
                            ? HexColor('#15141f')
                            : Theme.of(context).appBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HexColor(AppTheme.primaryColorString!).withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Autos",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                                homeController.vehiculos.length.toString(),
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24,
                                    ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Get.to(() => PagosPendientesScreen(),
                              transition: Transition.downToUp,
                              duration: const Duration(milliseconds: 500));
                        },
                        child: circleCard(
                          image: DefaultImages.topup,
                          title: "Pagar",
                        ),
                      ),
                      InkWell(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {},
                        child: circleCard(
                          image: DefaultImages.withdraw,
                          title: "Retirar",
                        ),
                      ),
                      InkWell(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Get.to(
                            () => ReservaScreen(),
                            binding: BindingsBuilder(() {
                              Get.delete<ReservaController>();
                              Get.create(() => ReservaController());
                            }),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                        child: circleCard(
                          image: DefaultImages.transfer,
                          title: "Reservar",
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withOpacity(0.10),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pagos previos",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Historial de Reservas",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          Get.to(() => PagosPendientesScreen());
                                        },
                                        icon: const Icon(Icons.payment),
                                        label: const Text("Ver solo Pendientes"),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          _mostrarDialogoAgregarVehiculo(context);
                                        },
                                        icon: const Icon(Icons.add_circle),
                                        label: const Text("Agregar Vehículo"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...homeController.todasLasReservas.map((reserva) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: const Icon(Icons.receipt_long),
                                    title: Text("Reserva: ${reserva.codigoReserva}"),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Fecha Inicio: ${UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio)}"),
                                        Text("Estado Pago: ${reserva.estadoPago}"),
                                        Text("Vehículo: ${reserva.chapaAuto}"),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "₲${UtilesApp.formatearGuaranies(reserva.monto)}",
                                          style: TextStyle(
                                            color: reserva.estadoPago == "PAGADO" ? Colors.green : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _mostrarDialogoAgregarVehiculo(BuildContext context) {
    final TextEditingController chapaController = TextEditingController();
    final TextEditingController marcaController = TextEditingController();
    final TextEditingController modeloController = TextEditingController();
    final TextEditingController colorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar Vehículo"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: chapaController,
                decoration: const InputDecoration(labelText: "Chapa"),
              ),
              TextField(
                controller: marcaController,
                decoration: const InputDecoration(labelText: "Marca"),
              ),
              TextField(
                controller: modeloController,
                decoration: const InputDecoration(labelText: "Modelo"),
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: "Color"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              if (chapaController.text.isNotEmpty &&
                  marcaController.text.isNotEmpty &&
                  modeloController.text.isNotEmpty &&
                  colorController.text.isNotEmpty) {
                final nuevoVehiculo = Vehiculo(
                  chapa: chapaController.text,
                  marca: marcaController.text,
                  modelo: modeloController.text,
                  color: colorController.text,
                );
                homeController.agregarVehiculo(nuevoVehiculo);
                if (Get.isRegistered<ReservaController>()) {
                  Get.find<ReservaController>().cargarAutosDelCliente();
                }
                Navigator.pop(context);
              }
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfirmarEliminarVehiculo(BuildContext context, String chapa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Vehículo"),
        content: Text("¿Estás seguro de eliminar el vehículo con chapa $chapa?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              homeController.eliminarVehiculo(chapa);
              Navigator.pop(context);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}
