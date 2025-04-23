import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapWithPolyline extends StatefulWidget {
  const MapWithPolyline({super.key});

  @override
  State<MapWithPolyline> createState() => _MapWithPolylineState();
}

class _MapWithPolylineState extends State<MapWithPolyline> {
  GoogleMapController? _mapController;
  LatLng? currentPosition;
  Map<String, dynamic>? bestRoute;
  Map<String, dynamic>? nearestStop;
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) => _findNearestRoute());
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _findNearestRoute() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('routes').get();

    double minDistance = double.infinity;
    Map<String, dynamic>? closestRoute;
    Map<String, dynamic>? closestStop;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final stops = List.from(data['stops']);

      for (var stop in stops) {
        final distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          stop['lat'],
          stop['lng'],
        );

        if (distance < minDistance) {
          minDistance = distance;
          closestRoute = data;
          closestStop = stop;
        }
      }
    }

    setState(() {
      bestRoute = closestRoute;
      nearestStop = closestStop;
    });

    _drawPolyline();
  }

  Future<void> _drawPolyline() async {
    if (currentPosition == null || nearestStop == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      'TU_API_KEY_DE_GOOGLE_MAPS', // <-- Sustituye por tu API key
      PointLatLng(currentPosition!.latitude, currentPosition!.longitude),
      PointLatLng(nearestStop!['lat'], nearestStop!['lng']),
    );

    List<LatLng> polylineCoords = result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    setState(() {
      polylines.add(Polyline(
        polylineId: const PolylineId('ruta'),
        color: Colors.blue,
        width: 5,
        points: polylineCoords,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentPosition!,
                zoom: 14,
              ),
              myLocationEnabled: true,
              polylines: polylines,
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                if (nearestStop != null)
                  Marker(
                    markerId: const MarkerId('nearestStop'),
                    position: LatLng(nearestStop!['lat'], nearestStop!['lng']),
                    infoWindow: InfoWindow(title: nearestStop!['name']),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
              },
            ),
    );
  }
}
