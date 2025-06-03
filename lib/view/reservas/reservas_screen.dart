import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';

class ReservaScreen extends StatelessWidget {
  final controller = Get.put(ReservaController());

  ReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reservar lugar")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Seleccionar auto",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Obx(() {
                  return DropdownButton<Auto>(
                    isExpanded: true,
                    value: controller.autoSeleccionado.value,
                    hint: const Text("Seleccionar auto"),
                    onChanged: (auto) {
                      controller.autoSeleccionado.value = auto;
                    },
                    items: controller.autosCliente.map((a) {
                      final nombre = "${a.chapa} - ${a.marca} ${a.modelo}";
                      return DropdownMenuItem(value: a, child: Text(nombre));
                    }).toList(),
                  );
                }),
                const Text("Seleccionar piso",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<Piso>(
                  isExpanded: true,
                  value: controller.pisoSeleccionado.value,
                  hint: const Text("Seleccionar piso"),
                  onChanged: (p) => controller.seleccionarPiso(p!),
                  items: controller.pisos
                      .map((p) => DropdownMenuItem(
                          value: p, child: Text(p.descripcion)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar lugar",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: controller.lugaresDisponibles
                        .where((l) =>
                            l.codigoPiso ==
                            controller.pisoSeleccionado.value?.codigo)
                        .map((lugar) {
                      final seleccionado =
                          lugar == controller.lugarSeleccionado.value;
                      final color = lugar.estado == "RESERVADO"
                          ? Colors.red
                          : seleccionado
                              ? Colors.green
                              : Colors.grey.shade300;

                      return GestureDetector(
                        onTap: lugar.estado == "DISPONIBLE"
                            ? () => controller.lugarSeleccionado.value = lugar
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                                color: seleccionado
                                    ? Colors.green.shade700
                                    : Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lugar.codigoLugar,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lugar.estado == "RESERVADO"
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar horarios",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date == null) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time == null) return;
                          controller.horarioInicio.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        },
                        icon: const Icon(Icons.access_time),
                        label: Obx(() => Text(
                              controller.horarioInicio.value == null
                                  ? "Inicio"
                                  : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioInicio.value!)} ${TimeOfDay.fromDateTime(controller.horarioInicio.value!).format(context)}",
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.horarioInicio.value ??
                                DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date == null) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time == null) return;
                          controller.horarioSalida.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        },
                        icon: const Icon(Icons.timer_off),
                        label: Obx(() => Text(
                              controller.horarioSalida.value == null
                                  ? "Salida"
                                  : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioSalida.value!)} ${TimeOfDay.fromDateTime(controller.horarioSalida.value!).format(context)}",
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Duración rápida",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _SelectionCard(
                  icon: Icons.access_time,
                  title: "Duración",
                  child: Obx(() => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Horas", style: TextStyle(fontSize: 16)),
                          Switch(
                            value: controller.esPorDias.value,
                            onChanged: (value) {
                              controller.esPorDias.value = value;
                              controller.duracionSeleccionada.value = value ? 1 : 1;
                              final inicio = controller.horarioInicio.value ?? DateTime.now();
                              controller.horarioInicio.value = inicio;
                              controller.horarioSalida.value = inicio.add(
                                value ? const Duration(days: 1) : const Duration(hours: 1)
                              );
                            },
                          ),
                          const Text("Días", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: ((controller.duracionSeleccionada.value == null || controller.duracionSeleccionada.value! < 1) ? 1 : controller.duracionSeleccionada.value!.toDouble()),
                        min: 1,
                        max: controller.esPorDias.value ? 7 : 8,
                        divisions: controller.esPorDias.value ? 6 : 7,
                        label: "${(controller.duracionSeleccionada.value == null || controller.duracionSeleccionada.value! < 1) ? 1 : controller.duracionSeleccionada.value} ${controller.esPorDias.value ? 'd' : 'h'}",
                        onChanged: (val) {
                          controller.duracionSeleccionada.value = val.round();
                          final inicio = controller.horarioInicio.value ?? DateTime.now();
                          controller.horarioInicio.value = inicio;
                          controller.horarioSalida.value = inicio.add(
                            controller.esPorDias.value 
                              ? Duration(days: val.round())
                              : Duration(hours: val.round())
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: (controller.esPorDias.value 
                          ? [1, 2, 3, 5, 7]
                          : [1, 2, 4, 6, 8]
                        ).map((d) => GestureDetector(
                          onTap: () {
                            controller.duracionSeleccionada.value = d;
                            final inicio = controller.horarioInicio.value ?? DateTime.now();
                            controller.horarioInicio.value = inicio;
                            controller.horarioSalida.value = inicio.add(
                              controller.esPorDias.value 
                                ? Duration(days: d)
                                : Duration(hours: d)
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (controller.duracionSeleccionada.value == d)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              "${d}${controller.esPorDias.value ? 'd' : 'h'}", 
                              style: TextStyle(
                                color: (controller.duracionSeleccionada.value == d)
                                    ? Colors.white
                                    : Colors.black87,
                              )
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final inicio = controller.horarioInicio.value;
                  final salida = controller.horarioSalida.value;
                  final auto = controller.autoSeleccionado.value;
                  final lugar = controller.lugarSeleccionado.value;

                  if (inicio == null || salida == null) return const SizedBox();

                  final minutos = salida.difference(inicio).inMinutes;
                  final horas = minutos / 60;
                  final monto = (horas * 10000).round();

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long, 
                                color: Theme.of(context).colorScheme.primary
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Resumen de Reserva",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          if (auto != null) ...[
                            _ResumenItem(
                              icon: Icons.directions_car,
                              label: "Vehículo",
                              value: "${auto.marca} ${auto.modelo} (${auto.chapa})",
                            ),
                          ],
                          if (lugar != null) ...[
                            _ResumenItem(
                              icon: Icons.local_parking,
                              label: "Lugar",
                              value: lugar.codigoLugar,
                            ),
                          ],
                          _ResumenItem(
                            icon: Icons.access_time,
                            label: "Duración",
                            value: "${controller.esPorDias.value ? 'Días' : 'Horas'}: ${controller.duracionSeleccionada.value ?? 1}",
                          ),
                          _ResumenItem(
                            icon: Icons.calendar_today,
                            label: "Inicio",
                            value: "${UtilesApp.formatearFechaDdMMAaaa(inicio)} ${TimeOfDay.fromDateTime(inicio).format(context)}",
                          ),
                          _ResumenItem(
                            icon: Icons.calendar_today,
                            label: "Fin",
                            value: "${UtilesApp.formatearFechaDdMMAaaa(salida)} ${TimeOfDay.fromDateTime(salida).format(context)}",
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Monto estimado:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₲${UtilesApp.formatearGuaranies(monto)}",
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
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.isReserving.value ? null : () async {
                      final confirmada = await controller.confirmarReserva();

                      if (confirmada) {
                        Get.snackbar(
                          "Reserva",
                          "Reserva realizada con éxito",
                          snackPosition: SnackPosition.BOTTOM,
                        );

                        await Future.delayed(
                            const Duration(milliseconds: 2000));

                        Get.back();
                      } else {
                        Get.snackbar(
                          "Error",
                          "Verificá que todos los campos estén completos",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                      }
                    },
                    child: controller.isReserving.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Confirmar Reserva",
                            style: TextStyle(fontSize: 16),
                          ),
                  )),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SelectionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResumenItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
      ),
    );
  }
}
