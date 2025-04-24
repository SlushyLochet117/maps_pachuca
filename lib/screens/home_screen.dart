import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps_pachuca/screens/buscar_ruta_screen.dart';
import 'package:maps_pachuca/screens/rutas_con_paradas_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  bool _isMenuExpanded = false;

  final LatLng _pachucaCenter = const LatLng(20.1235, -98.7364);

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadRoutesFromFirebase();
    _listenToNotifications();
    _getTokenAndPrint();
  }

  Future<void> _getTokenAndPrint() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('🔑 Token FCM: $token');
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _loadCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: const MarkerId('current_position'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Tú estás aquí'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 14),
    );
  }

  Future<void> _loadRoutesFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance.collection('rutas').get();

    Set<Marker> loadedMarkers = {};
    Set<Polyline> loadedPolylines = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final List<dynamic> paradas = data['paradas'];

      List<LatLng> polylinePoints = [];

      for (var parada in paradas) {
        LatLng point = LatLng(parada['lat'], parada['lng']);
        polylinePoints.add(point);

        loadedMarkers.add(
          Marker(
            markerId: MarkerId('${doc.id}_${parada['nombre']}'),
            position: point,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
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
  }

  void _centerToPachuca() {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_pachucaCenter, 14),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Sección ${["Inicio", "Notificaciones", "Perfil"][index]}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition:
                CameraPosition(target: _pachucaCenter, zoom: 13),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          // Botón de menú
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'menuBtn',
              onPressed: () =>
                  setState(() => _isMenuExpanded = !_isMenuExpanded),
              backgroundColor: Colors.white,
              child: Icon(
                _isMenuExpanded ? Icons.close : Icons.menu,
                color: Colors.blue[800],
              ),
            ),
          ),

          // Menú lateral
          if (_isMenuExpanded)
            Positioned(
              top: 110,
              left: 20,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuOption(Icons.directions_bus, 'Rutas'),
                      _buildMenuOption(Icons.bus_alert, 'Paradas'),
                      _buildMenuOption(Icons.star, 'Favoritos'),
                      _buildMenuOption(Icons.settings, 'Configuración'),
                    ],
                  ),
                ),
              ),
            ),

          // Botón centrar ubicación
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'myLoc',
              onPressed: _loadCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.blue[800]),
            ),
          ),

          // Botón centrar Pachuca
          Positioned(
            bottom: 180,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'pachucaLoc',
              onPressed: _centerToPachuca,
              backgroundColor: Colors.white,
              child: Icon(Icons.location_city, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[800],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == "Rutas") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BuscarRutaScreen()));
        } else if (label == "Paradas") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RutasConParadasScreen()));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Sección: $label')));
        }
        setState(() => _isMenuExpanded = false);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[800]),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[800])),
          ],
        ),
      ),
    );
  }

  void _listenToNotifications() {
    // Notificación en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? 'Sin título';
        final body = message.notification!.body ?? 'Sin contenido';
        _showNotificationDialog(title, body);
      }
    });

    // Notificación al abrir la app desde segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? 'Notificación';
        final body = message.notification!.body ?? '';
        _showNotificationDialog(title, body);
        // Aquí puedes redirigir a otra pantalla si quieres
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
