import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapService {
  static const String _googleMapsKey = 'TU_API_KEY';

  Future<List<LatLng>> getRouteCoordinates(
      LatLng origin, LatLng destination) async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      _googleMapsKey,
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    return result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  static Set<Marker> getBusStops() {
    // Aquí cargarías las paradas reales desde Firestore
    return {
      Marker(
        markerId: MarkerId('central'),
        position: LatLng(20.1260, -98.7360),
        infoWindow: InfoWindow(title: 'Parada Central'),
      ),
      // Más marcadores...
    };
  }
}
