import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:maps_pachuca/screens/buscar_ruta_screen.dart';
import 'package:maps_pachuca/screens/notificaciones_screen.dart';
import 'package:maps_pachuca/screens/perfil_screen.dart';
import 'package:maps_pachuca/screens/rutas_con_paradas_screen.dart';
import 'package:maps_pachuca/screens/configuracionscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  int _selectedIndex = 0;

  final LatLng _pachucaCenter = const LatLng(20.1235, -98.7364);

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadRoutesFromFirebase();
    _listenToNotifications();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _loadCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('current_position'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(title: 'Tú estás aquí'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14),
      );
    } catch (e) {
      print("Error obteniendo ubicación: $e");
    }
  }

  Future<void> _loadRoutesFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('rutas').get();

      Set<Marker> loadedMarkers = {};
      Set<Polyline> loadedPolylines = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic> paradas = data['paradas'];

        List<LatLng> polylinePoints = [];

        for (var parada in paradas) {
          LatLng point = LatLng(parada['lat'], parada['lng']);
          polylinePoints.add(point);

          loadedMarkers.add(
            Marker(
              markerId: MarkerId('${doc.id}_${parada['nombre']}'),
              position: point,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(title: parada['nombre']),
            ),
          );
        }

        loadedPolylines.add(
          Polyline(
            polylineId: PolylineId(doc.id),
            color: Colors.blue,
            width: 5,
            points: polylinePoints,
          ),
        );
      }

      setState(() {
        _markers.addAll(loadedMarkers);
        _polylines.addAll(loadedPolylines);
      });
    } catch (e) {
      print("Error cargando rutas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Barra superior con título
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título centrado
                    Expanded(
                      child: Center(
                        child: Text(
                          'Mapas Pachuca',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Botón de ubicación actual
                    IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      onPressed: () {
                        if (_currentPosition != null) {
                          mapController.animateCamera(
                            CameraUpdate.newLatLngZoom(_currentPosition!, 14),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Mapa principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                        target: _pachucaCenter, zoom: 13),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                ),
              ),
            ),

            // Barra inferior de navegación ampliada
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavButton(Icons.directions_bus, 'Paradas', 1, 
                      const RutasConParadasScreen()),
                  _buildNavButton(Icons.search, 'Buscar', 2, 
                      const BuscarRutaScreen()),
                  _buildNavButton(Icons.notifications, 'Notificaciones', 3,
                      const NotificacionesScreen()),
                  _buildNavButton(Icons.person, 'Perfil', 4,
                      const PerfilScreen()),
                  _buildNavButton(Icons.settings, 'Ajustes', 5,
                      const ConfiguracionScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
      IconData icon, String label, int index, [Widget? screen]) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: _selectedIndex == index
                  ? Colors.greenAccent
                  : Colors.white70),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index
                  ? Colors.greenAccent
                  : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _listenToNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? 'Sin título';
        final body = message.notification!.body ?? 'Sin contenido';
        _showNotificationDialog(title, body);
      }
    });
  }

  void _showNotificationDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }
}