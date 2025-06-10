import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/model/auto_model.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({Key? key}) : super(key: key);

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final homeController = Get.find<HomeController>();
  final TextEditingController chapaController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.isLightTheme == false
          ? const Color(0xff15141F)
          : Colors.white,
      appBar: AppBar(
        title: const Text("Mis Vehículos"),
        backgroundColor: AppTheme.isLightTheme == false
            ? const Color(0xff15141F)
            : Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarDialogoAgregarVehiculo(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (homeController.vehiculos.isEmpty) {
          return const Center(
            child: Text("No hay vehículos registrados"),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: homeController.vehiculos.length,
          itemBuilder: (context, index) {
            final vehiculo = homeController.vehiculos[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text("${vehiculo.marca} ${vehiculo.modelo}"),
                subtitle: Text("Chapa: ${vehiculo.chapa}\nColor: ${vehiculo.color}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _mostrarDialogoConfirmarEliminar(context, vehiculo);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _mostrarDialogoAgregarVehiculo(BuildContext context) {
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
                Navigator.pop(context);
                _limpiarControladores();
              }
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfirmarEliminar(BuildContext context, Vehiculo vehiculo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Vehículo"),
        content: Text("¿Estás seguro de eliminar el vehículo ${vehiculo.marca} ${vehiculo.modelo}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              homeController.eliminarVehiculo(vehiculo.chapa);
              Navigator.pop(context);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  void _limpiarControladores() {
    chapaController.clear();
    marcaController.clear();
    modeloController.clear();
    colorController.clear();
  }

  @override
  void dispose() {
    chapaController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    colorController.dispose();
    super.dispose();
  }
} 