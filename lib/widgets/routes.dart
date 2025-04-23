import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadRoutesScreen extends StatelessWidget {
  const UploadRoutesScreen({super.key});

  Future<void> uploadRoutes() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final List<Map<String, dynamic>> routes = [
      {
        "name": "Ruta Tuzos - Centro",
        "color": "#FF5722",
        "stops": [
          {"name": "Plaza Tuzos", "lat": 20.0830, "lng": -98.7345},
          {"name": "UAEH", "lat": 20.0981, "lng": -98.7422},
          {"name": "Centro Pachuca", "lat": 20.1234, "lng": -98.7341},
        ]
      },
      {
        "name": "Ruta Villas - Centro",
        "color": "#4CAF50",
        "stops": [
          {"name": "Villas de Pachuca", "lat": 20.0950, "lng": -98.7500},
          {"name": "Hospital General", "lat": 20.1100, "lng": -98.7400},
          {"name": "Centro Pachuca", "lat": 20.1234, "lng": -98.7341},
        ]
      },
      {
        "name": "Ruta Real del Monte - Centro",
        "color": "#3F51B5",
        "stops": [
          {"name": "Real del Monte", "lat": 20.1350, "lng": -98.6730},
          {"name": "IMSS", "lat": 20.1220, "lng": -98.7100},
          {"name": "Centro Pachuca", "lat": 20.1234, "lng": -98.7341},
        ]
      },
      {
        "name": "Ruta ISSSTE - Centro",
        "color": "#9C27B0",
        "stops": [
          {"name": "Hospital ISSSTE", "lat": 20.1300, "lng": -98.7400},
          {"name": "Soriana", "lat": 20.1250, "lng": -98.7360},
          {"name": "Centro Pachuca", "lat": 20.1234, "lng": -98.7341},
        ]
      },
    ];

    for (var route in routes) {
      await firestore.collection('routes').add(route);
    }

    debugPrint("✅ Rutas subidas exitosamente.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subir rutas")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await uploadRoutes();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Rutas subidas con éxito")),
            );
          },
          child: const Text("Subir rutas a Firebase"),
        ),
      ),
    );
  }
}
