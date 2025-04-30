import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_pachuca/screens/detalle_parada_screen.dart';
import '../models/ruta.dart';

class ParadasDeRutaScreen extends StatelessWidget {
  final Ruta ruta;

  const ParadasDeRutaScreen({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Botón regresar y título
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Paradas de ${ruta.nombre}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Mapa con bordes redondeados (igual que en home)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Mismo radio que en home
                    child: SizedBox(
                      height: 200, // Altura fija como en home
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(ruta.paradas[0].lat, ruta.paradas[0].lng),
                          zoom: 14,
                        ),
                        markers: Set<Marker>.of(ruta.paradas.map((parada) {
                          return Marker(
                            markerId: MarkerId(parada.id),
                            position: LatLng(parada.lat, parada.lng),
                            infoWindow: InfoWindow(title: parada.nombre),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Marcadores verdes
                          );
                        })),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false, // Deshabilitar botón nativo
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Lista de paradas
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ruta.paradas.length,
                    itemBuilder: (context, index) {
                      final parada = ruta.paradas[index];
                      return Card(
                        color: Colors.white10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            parada.nombre,
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Ubicación: ${parada.lat.toStringAsFixed(4)}, ${parada.lng.toStringAsFixed(4)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleParadaScreen(
                                  paradaId: parada.id,
                                  paradaNombre: parada.nombre,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
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