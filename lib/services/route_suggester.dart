import 'package:maps_pachuca/models/ruta.dart';
import 'firebase_service.dart';
import 'package:geolocator/geolocator.dart';

class RouteSuggester {
  /// Filtra rutas cuya primera parada esté más cerca de la ubicación actual
  static Future<List<Ruta>> sugerirRutasCercanas(
    double userLat,
    double userLng,
    String destinoBuscado,
  ) async {
    final rutas = await FirebaseService.getRutas();

    rutas.sort((a, b) {
      double distanciaA = Geolocator.distanceBetween(
        userLat,
        userLng,
        a.paradas.first.lat,
        a.paradas.first.lng,
      );
      double distanciaB = Geolocator.distanceBetween(
        userLat,
        userLng,
        b.paradas.first.lat,
        b.paradas.first.lng,
      );
      return distanciaA.compareTo(distanciaB);
    });

    // Filtro básico por nombre del destino
    final rutasFiltradas = rutas.where((ruta) {
      return ruta.paradas.any(
          (p) => p.nombre.toLowerCase().contains(destinoBuscado.toLowerCase()));
    }).toList();

    return rutasFiltradas;
  }
}
