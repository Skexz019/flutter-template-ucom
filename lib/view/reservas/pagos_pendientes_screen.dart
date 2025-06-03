import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/utils/utiles.dart';

class PagosPendientesScreen extends StatelessWidget {
  final controller = Get.put(ReservaController());

  PagosPendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagos Pendientes"),
      ),
      body: Obx(() {
        if (controller.reservasPendientes.isEmpty) {
          return const Center(
            child: Text(
              "No hay pagos pendientes",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.reservasPendientes.length,
          itemBuilder: (context, index) {
            final reserva = controller.reservasPendientes[index];
            return Dismissible(
              key: Key(reserva.codigoReserva),
              direction: DismissDirection.horizontal,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: const Icon(Icons.cancel, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.green,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: const Icon(Icons.payment, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text("Confirmar Cancelación"),
                      content: Text("¿Está seguro que desea cancelar la reserva ${reserva.codigoReserva}?"),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text("Sí, Cancelar"),
                        ),
                      ],
                    ),
                  ) ?? false;
                } else if (direction == DismissDirection.startToEnd) {
                  return true;
                }
                return false;
              },
              onDismissed: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  controller.reservasPendientes.removeAt(index);
                  Get.snackbar("Cancelado", "La reserva ${reserva.codigoReserva} ha sido cancelada (funcionalidad pendiente)");
                } else if (direction == DismissDirection.startToEnd) {
                  final success = await controller.realizarPago(reserva.codigoReserva);
                  if (success) {
                    Get.snackbar(
                      "Éxito",
                      "Pago realizado correctamente",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade100,
                      colorText: Colors.green.shade900,
                    );
                  } else {
                    Get.snackbar(
                      "Error",
                      "No se pudo realizar el pago",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.red.shade900,
                    );
                  }
                }
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Reserva #${reserva.codigoReserva}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Pendiente",
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.directions_car,
                        label: "Vehículo",
                        value: reserva.chapaAuto,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: "Inicio",
                        value: UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: "Fin",
                        value: UtilesApp.formatearFechaDdMMAaaa(reserva.horarioSalida),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Monto a pagar:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₲${UtilesApp.formatearGuaranies(reserva.monto)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
} 