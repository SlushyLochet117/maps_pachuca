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

    setState(() => isLoading = true);

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
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Botón de regreso + título (igual que en otras pantallas)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Buscar Ruta',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resto del contenido (se mantiene igual)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      userLocation == null ? '📍 Obteniendo ubicación...' : '📍 Ubicación detectada ✅',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: destinoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Destino',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: buscarRutas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Buscar Ruta Cercana',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                        : rutasEncontradas.isEmpty
                            ? const Center(
                                child: Text('No se encontraron rutas.',
                                    style: TextStyle(color: Colors.white70)),
                              )
                            : ListView.builder(
                                itemCount: rutasEncontradas.length,
                                itemBuilder: (context, index) {
                                  final ruta = rutasEncontradas[index];
                                  return Card(
                                    color: Colors.white10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(ruta.nombre,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                        ruta.paradas.map((p) => p.nombre).join(' → '),
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}