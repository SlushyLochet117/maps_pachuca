import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  final LatLng _pachucaCenter =
      const LatLng(20.1235, -98.7364); // Coordenadas de Pachuca
  LatLng? _currentPosition;
  bool _isMenuExpanded = false;

  // Marcador para la posición central
  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('pachuca_center'),
      position: LatLng(20.1235, -98.7364),
      infoWindow: const InfoWindow(title: 'Pachuca de Soto'),
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _checkCurrentLocation();
  }

  void _checkCurrentLocation() async {
    // Simulamos obtener la ubicación actual (luego lo implementarás con GPS)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _currentPosition = const LatLng(20.1000, -98.7500); // Posición simulada
      _markers.add(
        Marker(
          markerId: const MarkerId('current_position'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Tú estás aquí'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  void _centerToPachuca() {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_pachucaCenter, 14),
    );
  }

  void _centerToCurrentLocation() {
    if (_currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 16),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obteniendo ubicación...')),
      );
      _checkCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _pachucaCenter,
              zoom: 13,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          // Botón de menú desplegable
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'menuButton',
              onPressed: () {
                setState(() => _isMenuExpanded = !_isMenuExpanded);
              },
              backgroundColor: Colors.white,
              child: Icon(
                _isMenuExpanded ? Icons.close : Icons.menu,
                color: Colors.blue[800],
              ),
            ),
          ),

          // Menú desplegable
          if (_isMenuExpanded)
            Positioned(
              top: 110,
              left: 20,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuOption(Icons.directions_car, 'Transporte'),
                      _buildMenuOption(Icons.local_taxi, 'Taxis'),
                      _buildMenuOption(Icons.directions_bus, 'Rutas'),
                      _buildMenuOption(Icons.star, 'Favoritos'),
                      _buildMenuOption(Icons.settings, 'Configuración'),
                    ],
                  ),
                ),
              ),
            ),

          // Botón para centrar en ubicación actual
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'locationButton',
              onPressed: _centerToCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.blue[800]),
            ),
          ),

          // Botón para centrar en Pachuca
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'pachucaButton',
              onPressed: _centerToPachuca,
              backgroundColor: Colors.white,
              child: Icon(Icons.location_city, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String text) {
    return InkWell(
      onTap: () {
        // Aquí implementarás la navegación a cada sección
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sección: $text')),
        );
        setState(() => _isMenuExpanded = false);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[800]),
            const SizedBox(width: 10),
            Text(text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[800],
                )),
          ],
        ),
      ),
    );
  }
}
