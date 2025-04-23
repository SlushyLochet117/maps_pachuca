import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/ruta.dart';
import '../services/location_service.dart';
import '../services/route_suggester.dart';

class BuscarRutaScreen extends StatefulWidget {
  const BuscarRutaScreen({super.key});

  @override
  State<BuscarRutaScreen> createState() => _BuscarRutaScreenState();
}

class _BuscarRutaScreenState extends State<BuscarRutaScreen> {
  final TextEditingController destinoController = TextEditingController();
  List<Ruta> rutasEncontradas = [];
  bool isLoading = false;
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionUsuario();
  }

  Future<void> _obtenerUbicacionUsuario() async {
    try {
      final location = await LocationService.getCurrentLocation();
      setState(() {
        userLocation = location;
      });
    } catch (e) {
      debugPrint("Error al obtener ubicación: $e");
    }
  }

  Future<void> buscarRutas() async {
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación no disponible')),
      );
      return;
    }

    final destino = destinoController.text.trim();
    if (destino.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final rutas = await RouteSuggester.sugerirRutasCercanas(
      userLocation!.latitude,
      userLocation!.longitude,
      destino,
    );

    setState(() {
      rutasEncontradas = rutas;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Ruta'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            userLocation == null
                ? const Text('Obteniendo ubicación...')
                : const Text('Ubicación detectada ✅'),
            TextField(
              controller: destinoController,
              decoration: const InputDecoration(labelText: 'Destino'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: buscarRutas,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Buscar Ruta Cercana'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : rutasEncontradas.isEmpty
                      ? const Text('No se encontraron rutas.')
                      : ListView.builder(
                          itemCount: rutasEncontradas.length,
                          itemBuilder: (context, index) {
                            final ruta = rutasEncontradas[index];
                            return Card(
                              child: ListTile(
                                title: Text(ruta.nombre),
                                subtitle: Text(
                                  ruta.paradas.map((p) => p.nombre).join(' → '),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
