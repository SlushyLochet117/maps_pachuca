import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_pachuca/screens/detalle_parada_screen.dart';
import '../models/ruta.dart';

class ParadasDeRutaScreen extends StatelessWidget {
  final Ruta ruta; // Recibimos la ruta con sus paradas

  const ParadasDeRutaScreen({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paradas de ${ruta.nombre}'),
      ),
      body: Column(
        children: [
          Expanded(
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
                );
              })),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: ruta.paradas.length,
            itemBuilder: (context, index) {
              final parada = ruta.paradas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(parada.nombre),
                  subtitle: Text('Ubicación: ${parada.lat}, ${parada.lng}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleParadaScreen(
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
        ],
      ),
    );
  }
}
